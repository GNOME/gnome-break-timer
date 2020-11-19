daemon_util_test_runner = executable(
    'tests-daemon-util',
    sources : [
        'daemon_util_runner.vala',
        'test_Countdown.vala',
        'test_StatefulTimer.vala'
    ],
    dependencies : [
        tests_lib_dep
    ]
)

test(
    'Run daemon-util tests',
    daemon_util_test_runner
)
