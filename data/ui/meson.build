blueprint_compiler = find_program('blueprint-compiler')

blueprints = custom_target(
    'blueprints',
    input: files(
        'settings-panels.blp',
    ),
    output: '.',
    command: [blueprint_compiler, 'batch-compile', '@OUTPUT@', '@CURRENT_SOURCE_DIR@', '@INPUT@'],
)

