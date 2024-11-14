# HOW IT WORKS

1. The "app" is a function that takes a list of strings (args) and performs the generation.
2. THe args are parsed using the `parseArgs` function.
3. The "generator" is a function that takes the parsed args and performs the generation.
4. A list of "insights" are generated. Insights are pieces of information that are extracted from files or annotations.
5. The insights are then used to generate the output.