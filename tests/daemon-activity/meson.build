daemon_activity_test_runner = executable(
    'tests-daemon-activity',
    sources : [
        'daemon_activity_runner.vala',
        'test_ActivityMonitor.vala'
    ],
    dependencies : [
        tests_lib_dep
    ]
)

test(
    'Run daemon-activity tests',
    daemon_activity_test_runner
)
