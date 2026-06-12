# TODO: Add comment block with details

using Printf, Statistics

struct Student
    firstname::String
    lastname::String
    homework::Vector{Int}
    tests::Vector{Int}
end

function main()
    filename, testweight, homeworkweight, _, _ = getuserinput()

    students = readfile(filename)

    sortstudents!(students)

    maxhomework = 0
    maxtests = 0

    for student in students 
        if length(student.homework) > maxhomework
            maxhomework = length(student.homework)
        end
        if length(student.tests) > maxtests
            maxtests = length(student.tests)
        end
    end

    classtestavg, classhomeworkavg, classavg = calculateclassaverages(students, testweight, homeworkweight)

    printreport(
        students,
        testweight,
        homeworkweight,
        classtestavg,
        classhomeworkavg,
        classavg,
        maxhomework,
        maxtests
    )
    
end

function getuserinput()
    print("""Welcome to the gradebook calculator test program. I am going to
		read students from an input data file. You will tell me the name of
		your input file.\n\n""")

    print("Enter the name of your input file: ")
    filename = readline()
    
    print("Enter the % amount to weight test in overall avg: ")
    testweightstring = readline()
    testweight = parse(Float64, testweightstring)
    homeworkweight = 100.0 - testweight

    @printf("Tests will be weighted %.1f%%, Homework weighted %.1f%% \n\n", testweight, homeworkweight)

    print("How many homework assignments are there? ")
    numhomework = readline()

    print("How many test grades are there? ")
    numtests = readline()

    return filename, testweight, homeworkweight, numhomework, numtests
end

function readfile(filename) 
    students = Student[]

    open(filename, "r") do file
        while !eof(file)
            nameline = strip(readline(file))

            if isempty(nameline)
                continue
            end

            nameparts = split(nameline)

            if length(nameparts) < 2
                println("Invalid name line: $nameline")
                continue
            end

            firstname = nameparts[1] # julia arrays start at 1
            lastname = nameparts[2]

            if eof(file)
                println("Missing test line for $nameline")
                break
            end
            tests = parsescores(readline(file))

            if eof(file)
                println("Missing homework line for $nameline")
                break
            end
            homework = parsescores(readline(file))

            push!(students, Student(firstname, lastname, homework, tests))
        end
    end
    return students
end

function sortstudents!(students) # The ! means that the function modifies an argument
    sort!(students, by = s -> (lowercase(s.lastname), lowercase(s.firstname)))
end

function calculateclassaverages(students, testweight, homeworkweight)
    classtestavg = 0.0
    classhomeworkavg = 0.0
    classoverallavg = 0.0

    for student in students
        testavg = mean(student.tests)
        homeworkavg = mean(student.homework)

        classtestavg += testavg
        classhomeworkavg += homeworkavg

        classoverallavg += testavg*(testweight/100.0) + homeworkavg*(homeworkweight/100.0)
    end

    if length(students) > 0
        count = length(students)
        
        classtestavg /= count
        classhomeworkavg /= count
        classoverallavg /= count
    end

    return classtestavg, classhomeworkavg, classoverallavg
end

function printreport(
    students, 
    testweight, 
    homeworkweight, 
    classtestavg, 
    classhomeworkavg, 
    classavg, 
    maxhomework, 
    maxtests
    )
    println()
    @printf("GRADE REPORT --- %d STUDENTS FOUND IN FILE\n", length(students))
    @printf("TEST WEIGHT: %.1f%%\n", testweight)
    @printf("HOMEWORK WEIGHT: %.1f%%\n", homeworkweight)
    @printf("CLASS TEST AVERAGE: %.1f\n", classtestavg)
    @printf("CLASS HOMEWORK AVERAGE: %.1f\n", classhomeworkavg)
    @printf("OVERALL AVERAGE is %.1f\n\n", classavg)

    @printf("%-20s : %8s %5s %12s %5s %10s\n",
        "STUDENT NAME",
        "TESTS",
        "",
        "HOMEWORKS",
        "",
        "AVG")

    println("---------------------------------------------------------------------")

    for student in students
        hwavg = mean(student.homework)
        testavg = mean(student.tests)

        total = hwavg * (homeworkweight / 100.0) + testavg * (testweight / 100.0)
        name = "$(student.lastname), $(student.firstname)"

        @printf("%-20s : %8.1f %5s %12.1f %5s %10.1f",
            name,
            testavg,
            "($(length(student.tests)))",
            hwavg,
            "($(length(student.homework)))",
            total)

        if length(student.homework) < maxhomework
            print(" ** may be missing a homework **")
        end
        if length(student.tests) < maxtests
            print(" ** may be missing a test **")
        end

        println()
    end

    println("---------------------------------------------------------------------")
    println("\nEnd of Program 1")

end

function parsescores(line)
    return parse.(Int, split(line))
end

main()