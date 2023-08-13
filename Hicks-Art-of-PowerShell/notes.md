# The Art of PowerShell Toolmaking

## Assertions

- PowerShell functions do one thing
- PowerShell functions write one type of object to the pipeline
  - You are __not__ returning a value
  - You are writing objects to the pipeline
- Package related functions into a module
  - This is your tool set

## Who Is Your User?

- What is their role?
- What is their PowerShell skill level?
- What need is your tool filling for them?
  - Why do they need your tool?
- What kind of behavior do you need to anticipate?
- How will they handle or accept errors?

## How Will It Be Used?

- How will they use your command or tool?
  - Are they expecting something very simple?
  - Are they expecting to use parameters to customize behavior?
- How will they discover it? (i.e. command naming)
  - Do you need a command alias?
- Will they pipe output from a command to your command?
- What kind of object input do you have to accommodate?
- Do you need to define parameters to support parameter binding?
  - Maybe you need aliases
  - Default values?
  - Do you need to support parameter sets?
    - Computername
    - Session
- Don't assume you know where parameter values will come from.
  - Use parameter validation
  - What are potential failures?
  - Reduce friction for the user
    - Don't make them do your work
  - Increase odds of success
- Will your command be part of a larger pipeline or script?
  - How will the user consume the output?
    - View
    - Export
    - Convert
  - What output will streamline the anticipated process?
    - Does it need to relate to other commands in your module?
- Separate formatting from output
  - Write the richest object you can to the pipeline
  - What default display makes the most sense?
  - Are there other ways the might want to view the data?
    - property aliases
    - property sets
    - script properties

## Where Will It Be Used?

- Is this an interactive tool or part of an automated process?
- How critical is performance?
- How do you need to handle errors?

## Recommended Practices

- Use parameter validation
- Write meaningful verbose, error, and warning messages
- Write rich, typed objects to the pipeline
- Do not include formatting in your code
  - Provide formatting outside of your code

## Summary

- Write code for a real person to use in a PowerShell environment
- Consider how they will pass parameters and data to your function
- Consider how they will consume or use output from your command
- Make your command as easy to use and as flexible as possible
  - Don't make the user do your work
- Increase the odds of success
