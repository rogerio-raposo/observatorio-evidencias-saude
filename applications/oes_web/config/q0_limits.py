"""Pure native PostgreSQL limit configuration, never server observations."""
import re


def execution_limits(environ):
    names = ('OES_MB_OC1_CONNECT_TIMEOUT_SECONDS', 'OES_MB_OC1_STATEMENT_TIMEOUT_MS', 'OES_MB_OC1_LOCK_TIMEOUT_MS')
    values = []
    for name in names:
        value = environ.get(name, '')
        if not isinstance(value, str) or re.fullmatch(r'[1-9][0-9]{0,9}', value) is None:
            raise RuntimeError('HOLD: explicit finite Q0 execution limits required')
        number = int(value)
        if number > 2147483647:
            raise RuntimeError('HOLD: Q0 execution limit out of range')
        values.append(number)
    if values[2] >= values[1]:
        raise RuntimeError('HOLD: Q0 lock budget must be below statement budget')
    return tuple(values)


def limited_options(options, limits):
    connect, statement, lock = limits
    return {**options, 'connect_timeout': connect,
            'options': options.get('options', '') + f' -c statement_timeout={statement} -c lock_timeout={lock}'}


def review_limit_options(options, baseline):
    """Legacy profiles stay valid; partial/arbitrary new options never do."""
    if set(options) - {'sslmode', 'options', 'connect_timeout'}:
        return False
    session = options.get('options', '')
    if 'connect_timeout' not in options:
        return session == baseline
    connect = options['connect_timeout']
    if type(connect) is not int or not 0 < connect <= 2147483647:
        return False
    match = re.fullmatch(re.escape(baseline) + r' -c statement_timeout=([1-9][0-9]{0,9}) -c lock_timeout=([1-9][0-9]{0,9})', session)
    return bool(match and 0 < int(match[2]) < int(match[1]) <= 2147483647)
