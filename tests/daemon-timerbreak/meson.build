daemon_timerbreak_test_runner = executable(
    'tests-daemon-timerbreak',
    sources : [
        'daemon_timerbreak_runner.vala',
        'test_TimerBreakController.vala'
    ],
    dependencies : [
        tests_lib_dep
    ]
)

test(
    'Run daemon-timerbreak tests',
    daemon_timerbreak_test_runner
)
