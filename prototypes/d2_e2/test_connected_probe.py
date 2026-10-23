import unittest
from run_connected_probe import MAX_RECORDS, SEED_PMIDS, SEARCH_QUERY, SEED_QUERY, execute


class ProbeTests(unittest.TestCase):
    def test_queries_are_bounded_and_separate_seeds_from_date(self):
        self.assertIn('2026/10/05', SEARCH_QUERY)
        self.assertIn('2026/10/23', SEARCH_QUERY)
        self.assertNotIn('2026/10/05', SEED_QUERY)
        for pmid in SEED_PMIDS:
            self.assertIn(pmid + '[uid]', SEED_QUERY)

    def test_complete_result(self):
        calls = []
        def search(term, *, retmax):
            calls.append((term, retmax))
            if len(calls) == 1:
                return {'pmids': list(SEED_PMIDS), 'count': 4,
                        'query_translation': '', 'warnings': {}}
            return {'pmids': ['12', '13'], 'count': 40, 'url': 'https://example.invalid',
                    'retrieved_at_utc': '2026-10-23T14:00:00+00:00',
                    'query_translation': 'translated', 'warnings': {}}
        r = execute(search=search, summary=lambda pmids: [{'pmid': p} for p in pmids],
                    pause=lambda _: None, clock=lambda: 'fixed')
        self.assertEqual('PASS', r['status'])
        self.assertEqual(40, r['retrieval']['total_count'])
        self.assertEqual(2, r['retrieval']['returned_count'])
        self.assertEqual([4, MAX_RECORDS], [x[1] for x in calls])

    def test_missing_seed_is_partial_not_silent_pass(self):
        n = 0
        def search(term, *, retmax):
            nonlocal n
            n += 1
            if n == 1:
                return {'pmids': list(SEED_PMIDS)[:3]}
            return {'pmids': [], 'count': 0, 'url': 'https://example.invalid',
                    'retrieved_at_utc': 'fixed'}
        r = execute(search=search, summary=lambda _: [], pause=lambda _: None,
                    clock=lambda: 'fixed')
        self.assertEqual('PARTIAL', r['status'])
        self.assertEqual([SEED_PMIDS[3]], r['seed_test']['missing_pmids'])

    def test_mismatched_records_is_partial(self):
        n = 0
        def search(term, *, retmax):
            nonlocal n
            n += 1
            if n == 1:
                return {'pmids': list(SEED_PMIDS)}
            return {'pmids': ['12', '13'], 'count': 2,
                    'url': 'https://example.invalid', 'retrieved_at_utc': 'fixed'}
        r = execute(search=search, summary=lambda _: [{'pmid':'12'}],
                    pause=lambda _: None, clock=lambda: 'fixed')
        self.assertEqual('PARTIAL', r['status'])

if __name__ == '__main__':
    unittest.main()
