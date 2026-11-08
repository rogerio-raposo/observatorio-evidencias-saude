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
