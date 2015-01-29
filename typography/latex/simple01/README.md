
### Use `cmake` for LaTeX document production

- only out-of-source builds are supported (see UseLATEX.cmake doc)

Mininimum steps necessary:

1. start at the project directory
2. create a new directory to contain all the temp and produced files  
`mkdir build`
3. `cd  build`
4. invoke `cmake` using as argument the path of the main project input files  
`cmake ..`
5. execute  
`make pdf` or `make dvi`, etc.
6 view in the appropriate viewer


