"""Single bounded, factual PubMed metadata probe (only executed explicitly)."""
from __future__ import annotations

import json
import os
import sys
import time
from datetime import datetime, timezone
from urllib.error import HTTPError, URLError

from ncbi_client import MAX_RECORDS, SEED_PMIDS, RetrievalError, esearch, esummary

# Concept terms follow OES Document 48; broadened variants are explicitly exploratory.
CONCEPT_QUERY = (
    'insomnia[Title/Abstract] AND ('
    '"digital cognitive behavioral therapy"[Title/Abstract] OR '
    '"digital cognitive behavioural therapy"[Title/Abstract] OR '
    '"internet cognitive behavioral therapy"[Title/Abstract] OR '
    '"internet cognitive behavioural therapy"[Title/Abstract] OR '
    '"online cognitive behavioral therapy"[Title/Abstract] OR '
    '"internet-delivered"[Title/Abstract] OR '
    '"dCBT-I"[Title/Abstract] OR '
    '"digital CBT-I"[Title/Abstract] OR '
    '"fully automated"[Title/Abstract])'
)
DESIGN_QUERY = (
    '(randomized controlled trial[Publication Type] OR randomized[Title/Abstract] '
    'OR randomised[Title/Abstract] OR systematic review[Publication Type] '
    'OR meta-analysis[Publication Type] OR "systematic review"[Title/Abstract] '
    'OR "meta-analysis"[Title/Abstract])'
)
SEED_QUERY = CONCEPT_QUERY + ' AND (' + ' OR '.join(p + '[uid]' for p in SEED_PMIDS) + ')'
SEARCH_QUERY = (CONCEPT_QUERY + ' AND ' + DESIGN_QUERY +
                ' AND ("2026/10/05"[Date - Publication] : "2026/10/23"[Date - Publication])')


def execute(*, search=esearch, summary=esummary, pause=time.sleep, clock=None):
    """Three bounded requests, no persistence, no scientific conclusion."""
    now = (clock or (lambda: datetime.now(timezone.utc).isoformat()))()
    seed = search(SEED_QUERY, retmax=len(SEED_PMIDS))
    seen = set(seed['pmids'])
    missing = sorted(set(SEED_PMIDS) - seen)
    pause(0.5)  # Stay well below NCBI's default 3 req/s without API key.
    found = search(SEARCH_QUERY, retmax=MAX_RECORDS)
    pause(0.5)
    records = summary(found['pmids']) if found['pmids'] else []
    received = {r['pmid'] for r in records}
    complete = received == set(found['pmids']) and len(records) == len(found['pmids'])
    status = 'PASS' if not missing and complete else 'PARTIAL'
    return {
        'activity': 'OES/D2-E2/A2', 'status': status, 'executed_at_utc': now,
        'source': 'NCBI PubMed E-utilities', 'mode': 'read_only_public_metadata',
        'target_product': 'OES-P-2026-000401', 'oes_baseline': '2026-10-04',
        'seed_test': {
            'literal_query': SEED_QUERY, 'requested_pmids': list(SEED_PMIDS),
            'returned_pmids': seed['pmids'], 'missing_pmids': missing,
            'query_translation': seed.get('query_translation'),
            'warnings': seed.get('warnings'),
        },
        'retrieval': {'literal_query': SEARCH_QUERY, 'total_count': found['count'],
                      'returned_count': len(found['pmids']), 'pmids': found['pmids'],
                      'query_translation': found.get('query_translation'),
                      'warnings': found.get('warnings'),
                      'url': found['url'], 'retrieved_at_utc': found['retrieved_at_utc']},
        'records': records,
        'limits': ['No systematic search coverage claim', 'No deduplication by trial',
                   'No eligibility, certainty or materiality assessment',
                   'No updates to the evidence sheet, currentness or gates'],
    }


def main() -> int:
    try:
        result = execute()
    except (HTTPError, URLError, TimeoutError, OSError, RetrievalError,
            KeyError, ValueError, TypeError) as exc:
        result = {
            'activity': 'OES/D2-E2/A2', 'status': 'FAIL',
            'error_type': type(exc).__name__,
            'error': str(exc)[:300],
            'executed_at_utc': datetime.now(timezone.utc).isoformat(),
            'note': 'Network or response failure; not evidence of an empty result set',
        }
    print(json.dumps(result, ensure_ascii=False, indent=2, sort_keys=True), flush=True)
    summary_file = os.environ.get('GITHUB_STEP_SUMMARY')
    if summary_file:
        with open(summary_file, 'a', encoding='utf-8') as fh:
            fh.write('## OES D2-E2/A2 — single NCBI probe\n')
            fh.write(f"**Status:** {result['status']}  \n")
            fh.write(f"**UTC:** {result['executed_at_utc']}  \n")
            if 'retrieval' in result:
                f = result['retrieval']
                fh.write(f"**Total:** {f['total_count']}  \n")
                fh.write(f"**Returned:** {f['returned_count']} / {MAX_RECORDS}  \n")
                fh.write(f"**PMIDs:** {', '.join(f['pmids']) or 'none'}  \n")
                fh.write(f"**Seed PMIDs missing:** {', '.join(result['seed_test']['missing_pmids']) or 'none'}  \n")
            else:
                fh.write(f"**Error class:** {result['error_type']}  \n")
            fh.write('Exploratory bibliographic retrieval only; no scientific gate promotion.\n')
    return 0 if result['status'] == 'PASS' else 2


if __name__ == '__main__':
    sys.exit(main())
