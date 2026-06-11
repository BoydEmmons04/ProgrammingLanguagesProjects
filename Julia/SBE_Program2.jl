# TODO: Add comment block with details

using Printf, FileIO, Statistics

struct Student
    firstname::String
    lastname::String
    homework::Vector{Int}
    tests::Vector{Int}

function main()
    filename, testweight, homeworkweight, _, _ = getuserinput()

    # TODO: call all functions from main

end

function getuserinput()
    print("""Welcome to the gradebook calculator test program. I am going to\n
		read students from an input data file. You will tell me the name of\n
		your input file.\n\n""")

    # TODO: Finish this function

    return filename, testweight, homeworkweight
end

# TODO: readFile(string)
# TODO: sortStudents(Student[])
# TODO: calculateClassAverages(Student[], float64, float64)
# TODO: printReport(everything)
# TODO: parseScores(string)
# TODO: average([]int)