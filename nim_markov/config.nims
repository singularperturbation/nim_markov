task build, "Compile the project":
    --app:console
    --d:release
    setCommand "c", "nim_markov"

# TODO - add a test directory with unittest
task tests, "Run all tests":
    exec "nim c -r nim_markov"
    setCommand "nop"

task documentation, "Generate documentation":
    exec "mkdir -p docout"
    exec "nim doc2 -o:docout/nim_markov.html nim_markov"
    setCommand "nop"

task clean, "Remove all generated files":
    exec "rm -rf docout nim_markov"
    setCommand "nop"
