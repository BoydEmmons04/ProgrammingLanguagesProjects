
using Printf, Statistics

# Student struct used for storing information for each student
struct Student
    first_name::String
    last_name::String
    homework_scores::Vector{Int}
    test_scores::Vector{Int}
end

"""
main()

Control the flow of the program. Call helper functions to gather input, compute, and output in a formatted report.

Arguments
---------
None

Returns
-------
Nothing

Example
-------
julia> main()
"""
function main()
    filename, test_weight, homework_weight, _, _ = get_user_input()

    students = read_file(filename)

    sorted_students_name = sort_students_by_name(students)
    grade_sorted_students = sort_students_by_grade(students, test_weight, homework_weight)

    max_homework = 0
    max_tests = 0

    for student in students 
        if length(student.homework_scores) > max_homework
            max_homework = length(student.homework_scores)
        end
        if length(student.test_scores) > max_tests
            max_tests = length(student.test_scores)
        end
    end

    class_test_avg, class_homework_avg, class_avg = calculate_class_averages(students, test_weight, homework_weight)

    print_report_header(
        sorted_students_name,
        test_weight,
        homework_weight,
        class_test_avg,
        class_homework_avg,
        class_avg
    )
    
    println("\n\nNAME-SORTED REPORT\n")
    print_report_table(
        sorted_students_name,
        test_weight,
        homework_weight,
        max_homework,
        max_tests
    )

    println("\n\nGRADE-SORTED REPORT\n")
    print_report_table(
        grade_sorted_students,
        test_weight,
        homework_weight,
        max_homework,
        max_tests
    )

    println("End of Program 2")
end

"""
get_user_input()

Prompts the user for filename, weight, and hw/test grades

Arguments
---------
None

Returns
-------
filename, test_weight, homework_weight, num_homework, num_tests

Example
-------
julia> filename, test_weight, homework_weight, num_homework, num_tests = get_user_input()
"""

function get_user_input()
    print("""Welcome to the gradebook calculator test program. I am going to
		read students from an input data file. You will tell me the name of
		your input file.\n\n""")

    print("Enter the name of your input file: ")
    filename = readline()
    
    print("Enter the % amount to weight test in overall avg: ")
    test_weight_string = readline()
    test_weight = parse(Float64, test_weight_string)
    homework_weight = 100.0 - test_weight

    @printf("Tests will be weighted %.1f%%, Homework weighted %.1f%% \n\n", test_weight, homework_weight)

    print("How many homework assignments are there? ")
    num_homework = readline()

    print("How many test grades are there? ")
    num_tests = readline()

    return filename, test_weight, homework_weight, num_homework, num_tests
end

"""
read_file(filename)

Opens the user specified file and extracts useful information into an array of Student objects

Arguments
---------
filename

Returns
-------
students[]

Example
-------
julia> students = read_file(filename)
"""

function read_file(filename) 
    students = Student[]

    open(filename, "r") do file
        while !eof(file)
            name_line = strip(readline(file))

            if isempty(name_line)
                continue
            end

            name_parts = split(name_line)

            if length(name_parts) < 2
                println("Invalid name line: $name_line")
                continue
            end

            first_name = name_parts[1] # julia arrays start at 1
            last_name = name_parts[2]

            if eof(file)
                println("Missing test line for $name_line")
                break
            end
            test_scores = parse_scores(readline(file))

            if eof(file)
                println("Missing homework line for $name_line")
                break
            end
            homework_scores = parse_scores(readline(file))

            push!(students, Student(first_name, last_name, homework_scores, test_scores))
        end
    end
    return students
end

function sort_students_by_name(students)
    return sort(students, by = s -> (lowercase(s.last_name), lowercase(s.first_name)))
end

function sort_students_by_grade(students, test_weight, homework_weight)
    return sort(students, by = s -> begin
        test_avg = mean(s.test_scores)
        hw_avg = mean(s.homework_scores)
        -(hw_avg*(homework_weight/100.0) + test_avg*(test_weight/100.0))
    end)
end

function calculate_class_averages(students, test_weight, homework_weight)
    class_test_avg = 0.0
    class_homework_avg = 0.0
    class_overall_avg = 0.0

    for student in students
        test_avg = mean(student.test_scores)
        homework_avg = mean(student.homework_scores)

        class_test_avg += test_avg
        class_homework_avg += homework_avg

        class_overall_avg += test_avg*(test_weight/100.0) + homework_avg*(homework_weight/100.0)
    end

    if length(students) > 0
        count = length(students)
        
        class_test_avg /= count
        class_homework_avg /= count
        class_overall_avg /= count
    end

    return class_test_avg, class_homework_avg, class_overall_avg
end

function print_report_header(
    sorted_students_name, 
    test_weight, 
    homework_weight, 
    class_test_avg, 
    class_homework_avg, 
    class_avg
    )
    println()
    @printf("GRADE REPORT --- %d STUDENTS FOUND IN FILE\n", length(sorted_students_name))
    @printf("TEST WEIGHT: %.1f%%\n", test_weight)
    @printf("HOMEWORK WEIGHT: %.1f%%\n", homework_weight)
    @printf("CLASS TEST AVERAGE: %.1f\n", class_test_avg)
    @printf("CLASS HOMEWORK AVERAGE: %.1f\n", class_homework_avg)
    @printf("OVERALL AVERAGE is %.1f\n\n", class_avg)
end

function print_report_table(
    sorted_students, 
    test_weight, 
    homework_weight, 
    max_homework, 
    max_tests
    )
    @printf("%-20s : %8s %5s %12s %5s %10s\n",
        "STUDENT NAME",
        "TESTS",
        "",
        "HOMEWORKS",
        "",
        "AVG")

    println("---------------------------------------------------------------------")

    for student in sorted_students
        hw_avg = mean(student.homework_scores)
        test_avg = mean(student.test_scores)

        total_avg = hw_avg * (homework_weight / 100.0) + test_avg * (test_weight / 100.0)
        display_name = "$(student.last_name), $(student.first_name)"

        @printf("%-20s : %8.1f %5s %12.1f %5s %10.1f",
            display_name,
            test_avg,
            "($(length(student.test_scores)))",
            hw_avg,
            "($(length(student.homework_scores)))",
            total_avg)

        if length(student.homework_scores) < max_homework
            print(" ** may be missing a homework **")
        end
        if length(student.test_scores) < max_tests
            print(" ** may be missing a test **")
        end

        println()
    end

    println("---------------------------------------------------------------------")

end

function parse_scores(line)
    return parse.(Int, split(line))
end

main()