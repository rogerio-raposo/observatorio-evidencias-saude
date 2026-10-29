"""GitHub ref single-attempt gate. No database access.

Only a future separately gated job may call consume(). Never retry after uncertain
API outcome. A tag deleted by a repository administrator breaks permanence.
"""
import json
import os
from urllib.error import HTTPError, URLError
from urllib.request import Request, urlopen

REF = "refs/tags/oes-q0-rollback-single-attempt-20261029"
REPOSITORY = "rogerio-raposo/observatorio-evidencias-saude"


class SingleUseHold(RuntimeError):
    pass


def classify_creation(status, ref_name, response_ref):
    """Accept only an exact 201 creation acknowledgement, fail closed otherwise."""
    if status == 201 and ref_name == REF and response_ref == REF:
        return "ATTEMPT_CONSUMED"
    raise SingleUseHold("HOLD: attempt unavailable, occupied or uncertain")


def consume():
    """Irreversible attempt marker. Not invoked by existing workflows.

    A caller must enforce a reviewed commit and ensure all preflights are
    completed before invoking, and must not retry after any exception.
    """
    if os.environ.get("OES_SINGLE_USE_CONSUME") != "APPROVED_ONCE":
        raise SingleUseHold("HOLD: consume gate absent")
    token = os.environ.get("GITHUB_TOKEN")
    sha = os.environ.get("GITHUB_SHA")
    if (not token or os.environ.get("GITHUB_REPOSITORY") != REPOSITORY
            or os.environ.get("GITHUB_REF") != "refs/heads/main"
            or not sha or len(sha) != 40
            or any(c not in "0123456789abcdef" for c in sha)):
        raise SingleUseHold("HOLD: invalid GitHub attempt provenance")
    body = json.dumps({"ref": REF, "sha": sha}).encode()
    req = Request("https://api.github.com/repos/" + REPOSITORY + "/git/refs",
                  data=body, method="POST", headers={
                      "Accept": "application/vnd.github+json",
                      "Authorization": "Bearer " + token,
                      "Content-Type": "application/json",
                      "X-GitHub-Api-Version": "2022-11-28",
                  })
    try:
        with urlopen(req, timeout=12) as response:
            status = response.status
            result = json.load(response)
    except (HTTPError, URLError, TimeoutError, ValueError, OSError) as exc:
        raise SingleUseHold("HOLD: attempt already consumed or outcome uncertain; never retry") from exc
    return classify_creation(status, REF, result.get("ref"))
