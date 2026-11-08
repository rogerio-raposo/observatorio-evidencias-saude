"""Q0 input contract only. No request identity resolution or persistence."""
from django import forms
from django.core.exceptions import PermissionDenied

from .question_preparation import (
    QuestionCommand, PreparationHold, PreparationConflict,
    Q0_IDENTIFIER_PATTERN, validate_register_q0,
)

Q0_MESSAGES = {
    "blocked": "Registro Q0 indisponível nesta versão. Nenhuma questão será gravada.",
    "unauthorized": "É necessário estar autenticado e ter permissão para preparar questões.",
    "identity": "Não foi possível confirmar o vínculo do preparador. O registro permanece indisponível.",
    "conflict": "A questão ou a solicitação conflita com um registro existente. Não substitua o texto original.",
    "before_write": "Esta tentativa não iniciou gravação. Preserve a solicitação; isso não confirma o resultado de tentativas anteriores.",
    "uncertain": "O resultado da tentativa não foi confirmado. Guarde os identificadores e não reenvie nem gere outra solicitação antes de verificar o resultado.",
}


def q0_failure_message(error):
    """Conservative future presentation; no exception text or success promotion."""
    if isinstance(error, PreparationConflict):
        return Q0_MESSAGES["conflict"]
    if isinstance(error, PermissionDenied):
        return Q0_MESSAGES["unauthorized"]
    observation = getattr(error, "q0_observation", None)
    if (isinstance(error, PreparationHold) and isinstance(observation, dict)
            and observation.get("outcome") == "ABSENT"
            and observation.get("scope") == "THIS_ATTEMPT"
            and observation.get("automatic_retry") is False):
        return Q0_MESSAGES["before_write"]
    return Q0_MESSAGES["uncertain"]


class Q0RegistrationForm(forms.Form):
    request_id = forms.RegexField(
        regex=r"\A" + Q0_IDENTIFIER_PATTERN + r"\Z", max_length=128, strip=False,
        label="Identificador da solicitação",
        help_text="Use letras, números, ponto, hífen, sublinhado ou dois-pontos. Preserve este identificador para verificar uma tentativa.",
        error_messages={"required": "Informe o identificador da solicitação.", "invalid": "Use um identificador sem espaços, com até 128 caracteres.", "max_length": "Use no máximo 128 caracteres no identificador."},
    )
    question_id = forms.RegexField(
        regex=r"\A" + Q0_IDENTIFIER_PATTERN + r"\Z", max_length=128, strip=False,
        label="Identificador único da questão",
        help_text="O identificador deve estar disponível; uma questão existente não será sobrescrita.",
        error_messages={"required": "Informe o identificador da questão.", "invalid": "Use um identificador sem espaços, com até 128 caracteres.", "max_length": "Use no máximo 128 caracteres no identificador."},
    )
    original_text = forms.CharField(
        max_length=10000, strip=False, widget=forms.Textarea(attrs={"rows": 6}),
        label="Texto original da questão",
        help_text="Escreva a pergunta original, sem normalização ou campos Q1/Q2. O texto será preservado como informado.",
        error_messages={"required": "Informe o texto original da questão.", "max_length": "Use no máximo 10000 caracteres no texto original.", "null_characters_not_allowed": "O texto não pode conter caracteres nulos."},
    )

    def clean_original_text(self):
        value = self.cleaned_data["original_text"]
        if not value.strip():
            raise forms.ValidationError("Informe o texto original da questão.")
        return value

    def clean(self):
        cleaned = super().clean()
        allowed = set(self.fields) | {"csrfmiddlewaretoken"}
        if set(self.data) - allowed:
            raise forms.ValidationError("Dados adicionais não são aceitos no registro Q0. A identidade do preparador é confirmada pela aplicação.")
        if hasattr(self.data, "getlist") and any(len(self.data.getlist(k)) > 1 for k in allowed):
            raise forms.ValidationError("Informe apenas um valor para cada campo.")
        return cleaned

    def to_command(self):
        if not self.is_valid():
            raise PreparationHold("HOLD: invalid Q0 form")
        return validate_register_q0(QuestionCommand(
            self.cleaned_data["request_id"], self.cleaned_data["question_id"],
            0, self.cleaned_data["original_text"],
        ))


def prepare_q0_submission(*, user, data):
    """Offline application/presentation seam, never called by operational POST.

    No backend injection. A normal service return AND its D3 evidence are needed.
    """
    from .preparation_auth import require_question_preparer
    from .question_preparation import register_authenticated_q0
    from .question_orm_q0_repository_dormant import _application_q0_scope
    form = Q0RegistrationForm(data)
    context = {"form": form, "messages": Q0_MESSAGES}
    scope = None
    try:
        require_question_preparer(user)
        if not form.is_valid():
            return 400, context
        command = form.to_command()
        with _application_q0_scope(user=user, command=command) as scope:
            result = register_authenticated_q0(user=user, command=command)
            evidence = scope.observation
            if (result != {"status": "PREPARATORY_ONLY", "question_id": command.question_id, "version": 1}
                    or not isinstance(evidence, dict) or evidence.get("outcome") != "PERSISTED"
                    or evidence.get("scope") != "Q0_RECORDS" or evidence.get("automatic_retry") is not False):
                raise PreparationHold("HOLD: normal verified Q0 completion required")
        context["result_message"] = "Registro Q0 íntegro confirmado por leitura independente."
        context["confirmed_question_id"] = command.question_id
        return 200, context
    except PermissionDenied:
        context["result_message"] = Q0_MESSAGES["unauthorized"]
        return 403, context
    except Exception as error:
        observation = getattr(error, "q0_observation", None)
        # Only D1's pre-INSERT typed conflict is presented as definitive.
        conflict = isinstance(error, PreparationConflict) and scope is not None and scope.conflict_before_insert
        context["result_message"] = Q0_MESSAGES["conflict"] if conflict else q0_failure_message(
            error if not isinstance(error, PreparationConflict) else PreparationHold("HOLD"))
        return (409 if conflict else 503), context


def prepare_q0_recovery(*, user, data):
    """Actor-scoped READ ONLY presentation. Never resubmits a command."""
    from .preparation_auth import require_question_preparer
    from .question_preparation import review_registered_q0
    form = Q0RegistrationForm(data)
    context = {"form": form, "messages": Q0_MESSAGES}
    try:
        require_question_preparer(user)
        if not form.is_valid():
            return 400, context
        observation = review_registered_q0(user=user, command=form.to_command())
        outcome = observation.get("outcome") if isinstance(observation, dict) else None
        if (outcome == "PERSISTED" and observation.get("scope") == "Q0_RECORDS"
                and observation.get("automatic_retry") is False):
            context["result_message"] = "Registro Q0 íntegro confirmado por leitura independente."
            context["confirmed_question_id"] = form.cleaned_data["question_id"]
            return 200, context
        # Preserve classification without treating absence as registration/retry.
        if (outcome == "ABSENT" and observation.get("scope") in ("Q0_RECORDS", "THIS_ATTEMPT")
                and observation.get("automatic_retry") is False):
            context["recovery_outcome"] = "ABSENT"
            context["recovery_scope"] = observation["scope"]
            context["result_message"] = "Ausência demonstrada no escopo informado. Preserve os identificadores; não reenvie automaticamente."
        else:
            context["recovery_outcome"] = "INDETERMINATE"
            context["result_message"] = Q0_MESSAGES["uncertain"]
        return 503, context
    except PermissionDenied:
        context["result_message"] = Q0_MESSAGES["unauthorized"]
        return 403, context
    except Exception:
        context["result_message"] = Q0_MESSAGES["uncertain"]
        return 503, context


class Q1ProposalForm(Q0RegistrationForm):
    expected_version = forms.IntegerField(min_value=1, label="Versão esperada")
    normalized_text = forms.CharField(max_length=10000, strip=False, label="Proposta de texto normalizado",
                                      widget=forms.Textarea(attrs={"rows": 6}))
    justification = forms.CharField(max_length=10000, strip=False, label="Justificativa da proposta",
                                   widget=forms.Textarea(attrs={"rows": 3}))

    def clean(self):
        cleaned = super().clean()
        for name in ("normalized_text", "justification"):
            value = cleaned.get(name)
            if isinstance(value, str) and not value.strip():
                self.add_error(name, "Informe um texto não vazio.")
        return cleaned

    def to_command(self):
        from .question_preparation import validate_propose_q1
        if not self.is_valid():
            raise PreparationHold("HOLD: invalid Q1 form")
        return validate_propose_q1(QuestionCommand(
            self.cleaned_data["request_id"], self.cleaned_data["question_id"],
            self.cleaned_data["expected_version"], self.cleaned_data["original_text"],
            self.cleaned_data["normalized_text"], self.cleaned_data["justification"]))


def prepare_q1_proposal(*, user, data, unit_of_work=None):
    """Offline-only presentation with the existing UoW supplied by tests."""
    from .preparation_auth import require_question_preparer
    from .pf_i03_q1_offline import present_authenticated_q1
    form = Q1ProposalForm(data)
    context = {"form": form}
    try:
        require_question_preparer(user)
        if not form.is_valid():
            context["outcome"] = "INVALID"
            return 400, context
        context["proposal"] = present_authenticated_q1(user=user, command=form.to_command(), unit_of_work=unit_of_work)
        context["outcome"] = "OFFLINE_RECEIPT_VERIFIED"
        context["result_message"] = "Proposta Q1 verificada no contrato offline com recibo simulado. Não comprova persistência conectada."
        return 200, context
    except PermissionDenied:
        context["outcome"] = "ACCESS_DENIED"
        context["result_message"] = Q0_MESSAGES["unauthorized"]
        return 403, context
    except PreparationConflict as error:
        # Conflicts in the supplied existing offline UoW precede mutation.
        # Contradictory/uncertain observations must never be reported as success.
        context["result_message"] = "A proposta conflita com a versão, solicitação ou responsabilidade da questão. Preserve os dados; não reenvie automaticamente."
        uncertain = getattr(error, "q0_observation", None) is not None
        context["outcome"] = "INDETERMINATE" if uncertain else "CONFLICT"
        return (503 if uncertain else 409), context
    except Exception:
        context["outcome"] = "UNAVAILABLE" if unit_of_work is None else "INDETERMINATE"
        context["result_message"] = "Proposta não confirmada. Preserve os identificadores e o texto; não reenvie nem gere outra solicitação automaticamente."
        if unit_of_work is None:
            context["result_message"] = "Registro Q1 operacional indisponível. Nenhum backend foi iniciado por esta entrada; preserve os dados da proposta."
        return 503, context


class Q2RoutingForm(Q1ProposalForm):
    """Reference an existing Q1, then prepare a nonpersistent Q2 proposal."""
    from .pf_i03_q2_routing_offline import METHODS, DEPTHS, MAINTENANCE
    expected_version = None
    q1_version = forms.IntegerField(min_value=2, label="Versão Q1 de referência")
    operational_question = forms.CharField(max_length=10000, strip=False, label="Pergunta operacional", widget=forms.Textarea)
    population = forms.CharField(max_length=10000, strip=False, label="População")
    exposure_or_intervention = forms.CharField(max_length=10000, strip=False, label="Intervenção ou exposição")
    comparator = forms.CharField(max_length=10000, strip=False, label="Comparador")
    outcomes = forms.CharField(max_length=10000, strip=False, label="Desfechos (um por linha)", widget=forms.Textarea)
    methodological_class = forms.ChoiceField(choices=[(c,c) for c in sorted(METHODS)], label="Classe metodológica proposta")
    depth = forms.ChoiceField(choices=[(c,c) for c in sorted(DEPTHS)], label="Profundidade proposta")
    maintenance = forms.ChoiceField(choices=[(c,c) for c in sorted(MAINTENANCE)], label="Manutenção proposta")
    routing_justification = forms.CharField(max_length=10000, strip=False, label="Justificativa do roteamento", widget=forms.Textarea)

    def __init__(self, *args, **kwargs):
        super().__init__(*args, **kwargs)
        self.fields["request_id"].label = "Identificador da solicitação Q1 existente"
        self.fields["normalized_text"].label = "Texto Q1 de referência (literal)"
        self.fields["justification"].label = "Justificativa Q1 de referência (literal)"

    def clean(self):
        cleaned = super().clean()
        if "question_id" in cleaned and not cleaned["question_id"].startswith("OES-SYNTH-Q0-"):
            self.add_error("question_id", "Este percurso aceita somente questões sintéticas OES-SYNTH-Q0-.")
        for name in ("operational_question", "population", "exposure_or_intervention", "comparator", "routing_justification"):
            value = cleaned.get(name)
            if isinstance(value, str) and not value.strip():
                self.add_error(name, "Informe um texto não vazio.")
        if "outcomes" in cleaned and any(not line.strip() for line in cleaned["outcomes"].splitlines()):
            self.add_error("outcomes", "Informe um desfecho não vazio por linha.")
        return cleaned

    def to_command(self):
        from .question_preparation import validate_propose_q1
        if not self.is_valid():
            raise PreparationHold("HOLD: invalid Q2 reference form")
        # Translate the explicit resulting Q1 version to its command's expected
        # version. The actual stored receipt must still match it exactly.
        return validate_propose_q1(QuestionCommand(self.cleaned_data["request_id"], self.cleaned_data["question_id"],
            self.cleaned_data["q1_version"] - 1, self.cleaned_data["original_text"],
            self.cleaned_data["normalized_text"], self.cleaned_data["justification"]))

    def to_proposal(self):
        from .pf_i03_q2_routing_offline import Q2RoutingProposal
        if not self.is_valid():
            raise PreparationHold("HOLD: invalid Q2 proposal form")
        c = self.cleaned_data
        return Q2RoutingProposal(c["question_id"], c["q1_version"], c["operational_question"], c["population"],
            c["exposure_or_intervention"], c["comparator"], tuple(c["outcomes"].splitlines()),
            c["methodological_class"], c["depth"], c["maintenance"], c["routing_justification"])


def prepare_q2_routing(*, user, data, unit_of_work=None):
    """Offline test seam. The HTTP GET page never invokes this adapter."""
    from .preparation_auth import require_question_preparer
    from .pf_i03_q2_routing_offline import present_authenticated_q2_routing
    form = Q2RoutingForm(data)
    context = {"form": form}
    try:
        require_question_preparer(user)
        if not form.is_valid():
            context["outcome"] = "INVALID"
            return 400, context
        result = present_authenticated_q2_routing(user=user, q1_command=form.to_command(),
                                                 proposal=form.to_proposal(), unit_of_work=unit_of_work)
        context.update(proposal=result, outcome="PROPOSED_OFFLINE_ONLY")
        return 200, context
    except PermissionDenied:
        context.update(outcome="ACCESS_DENIED", result_message=Q0_MESSAGES["unauthorized"])
        return 403, context
    except Exception:
        context.update(outcome="UNVERIFIED_PROVENANCE", result_message="Não foi possível verificar a referência Q1 e a responsabilidade. Preserve os dados; não há proposta persistida nem reenvio automático.")
        return 503, context
