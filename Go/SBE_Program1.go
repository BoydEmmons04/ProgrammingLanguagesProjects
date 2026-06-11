/*
Name: Boyd Emmons
Program Name: SBE_Program1.go
Class: CS 424 Summer 2026
Assignment 1: Gradebook Calculator in Go
Testing Environment:

	Go 1.26.3 Arch Linux
	Go 1.25.7 Windows 10
	Go Windows 10 Lab UAH

Commands: go run SBE_Program1.go

This is my work and may be rough around the edges in some places. Commenting inside of functions has been toned down to
encourage writing readable code with robust variable and function names. Functions were mostly designed around the
Single Responsibility Principle defined in "Clean Code" by Robert C Martin though not perfectly. The comment block
before each function should satisfy the requirements for documentation. Variable names use camelCase to follow Go
naming conventions which I didn't realize was strongly encouraged until the end of work on this assignment.

This program reads student information from a user specified file and calculates their test, homework, and overall
averages based on the user provided weights for the tests and homework. It also calculates the total class average
and counts the number of students read from the file. The program also handles missing grades and homework by
outputting a warning message next to the student's grade information. The code uses an array of Student structs
to hold the class information. Functions created for this project include getUserInput, readFile, sortStudents,
calculateClassAverages, and printReport. Error handling was largely ignored due to the instructions explicitly stating
that all input would be properly formatted.
*/
package main

import (
	"bufio"
	"fmt"
	"log"
	"os"
	"sort"
	"strconv"
	"strings"
)

// Student stores one student's name, homework grades, and test grades.
type Student struct {
	FirstName string
	LastName  string
	Homework  []int
	Tests     []int
}

// main() handles the overall flow of the program.
//
// This function gets the user's settings, reads the student data file,
// sorts the students, calculates the class average, and prints the final
// grade report. It is the main thread of execution for the project.
//
// Return Type: None
func main() {

	fileName, testWeight, homeworkWeight, _, _ := getUserInput()

	students, err := readFile(fileName)
	if err != nil {
		log.Fatalf("Error reading file: %v", err)
	}

	sortStudents(students)

	maxHomework := 0
	maxTests := 0

	for _, student := range students {
		if len(student.Homework) > maxHomework {
			maxHomework = len(student.Homework)
		}
		if len(student.Tests) > maxTests {
			maxTests = len(student.Tests)
		}
	}

	classTestAvg, classHomeworkAvg, classAvg :=
		calculateClassAverages(students, testWeight, homeworkWeight)

	printReport(
		students,
		testWeight,
		homeworkWeight,
		classTestAvg,
		classHomeworkAvg,
		classAvg,
		maxHomework,
		maxTests,
	)
}

// getUserInput() prompts the user for the program settings.
//
// This function reads the input file name, test weight, number of homework
// assignments, and number of tests from the keyboard. It also calculates the
// homework weight as the remaining percentage after the test weight.
//
// Return Types: string, float64, float64, int, int
func getUserInput() (string, float64, float64, int, int) {
	reader := bufio.NewReader(os.Stdin)

	fmt.Print(
		"Welcome to the gradebook calculator test program. I am going to\n",
		"read students from an input data file. You will tell me the name of\n",
		"your input file.\n\n",
	)

	fmt.Print("Enter the name of your input file: ")
	fileName, _ := reader.ReadString('\n')
	fileName = strings.TrimSpace(fileName)

	fmt.Print("Enter the % amount to weight test in overall avg: ")
	testWeightStr, _ := reader.ReadString('\n')
	testWeightStr = strings.TrimSpace(testWeightStr)
	fmt.Print("\n")

	testWeight, _ := strconv.ParseFloat(testWeightStr, 64)
	homeworkWeight := 100.0 - testWeight

	fmt.Printf("Tests will be weighted %.1f%%, Homework weighted %.1f%%\n\n", testWeight, homeworkWeight)

	fmt.Print("How many homework assignments are there? ")
	numHomeworkStr, _ := reader.ReadString('\n')
	numHomeworkStr = strings.TrimSpace(numHomeworkStr)
	numHomework, _ := strconv.Atoi(numHomeworkStr)

	fmt.Print("How many test grades are there? ")
	numTestsStr, _ := reader.ReadString('\n')
	numTestsStr = strings.TrimSpace(numTestsStr)
	numTests, _ := strconv.Atoi(numTestsStr)

	return fileName, testWeight, homeworkWeight, numHomework, numTests
}

// readFile() reads the input file and creates a Student struct for each student.
//
// This function accepts a file name, opens that file, and reads the student
// information line by line. The file is expected to store each student using
// three lines: first and last name, test scores, and homework scores. For each
// valid student entry, it stores the name, test scores, and homework scores in
// a Student struct and appends it to the students slice. It returns the completed
// student slice or an error if reading fails.
//
// Return Types: []Student, error
func readFile(fileName string) ([]Student, error) {

	file, err := os.Open(fileName)
	if err != nil {
		return nil, err
	}
	defer file.Close()

	scanner := bufio.NewScanner(file)

	var students []Student

	for {
		if !scanner.Scan() {
			break
		}

		nameLine := strings.TrimSpace(scanner.Text())
		if nameLine == "" {
			continue
		}

		nameParts := strings.Fields(nameLine)
		if len(nameParts) < 2 {
			fmt.Println("Invalid name line:", nameLine)
			continue
		}

		firstName := nameParts[0]
		lastName := nameParts[1]

		if !scanner.Scan() {
			fmt.Println("Missing test line for", nameLine)
			break
		}
		tests, _ := parseScores(scanner.Text())

		if !scanner.Scan() {
			fmt.Println("Missing homework line for", nameLine)
			break
		}
		homework, _ := parseScores(scanner.Text())

		students = append(students, Student{
			FirstName: firstName,
			LastName:  lastName,
			Homework:  homework,
			Tests:     tests,
		})
	}

	if err := scanner.Err(); err != nil {
		return nil, err
	}

	return students, nil

}

// sortStudents() sorts the students by last name, then first name.
//
// This function accepts the students slice and sorts it in place using the
// sort package. If two students have the same last name, their first names
// are used to decide the order. The comparison ignores capitalization.
//
// Return Type: None
func sortStudents(students []Student) {
	sort.Slice(students, func(i, j int) bool {
		if students[i].LastName == students[j].LastName {
			return strings.ToLower(students[i].FirstName) < strings.ToLower(students[j].FirstName)
		}
		return strings.ToLower(students[i].LastName) < strings.ToLower(students[j].LastName)
	})
}

// calculateClassAverages() calculates the class test, homework, and overall averages.
//
// This function accepts the students slice, test weight, and homework weight.
// It loops through each student, adds each student's test average, homework
// average, and weighted overall average, then divides each total by the number
// of students. It returns the class test average, class homework average, and
// class overall average as float64 values.
//
// Return Types: float64, float64, float64
func calculateClassAverages(students []Student, testWeight, homeworkWeight float64) (float64, float64, float64) {
	var classTestAvg float64
	var classHomeworkAvg float64
	var classOverallAvg float64

	for _, student := range students {
		testAvg := average(student.Tests)
		homeworkAvg := average(student.Homework)

		classTestAvg += testAvg
		classHomeworkAvg += homeworkAvg

		classOverallAvg +=
			testAvg*(testWeight/100.0) +
				homeworkAvg*(homeworkWeight/100.0)
	}

	if len(students) > 0 {
		count := float64(len(students))

		classTestAvg /= count
		classHomeworkAvg /= count
		classOverallAvg /= count
	}

	return classTestAvg, classHomeworkAvg, classOverallAvg
}

// printReport() prints the final grade report.
//
// This function accepts the students slice, grading weights, class averages, and
// maximum numbers of homework assignments and tests found in the file. It prints
// the report header, then loops through each student and prints their test average,
// homework average, weighted overall average, and any missing-grade warnings.
//
// Return Type: None
func printReport(
	students []Student,
	testWeight,
	homeworkWeight,
	classTestAvg,
	classHomeworkAvg,
	classAvg float64,
	maxHomework,
	maxTests int,
) {
	fmt.Println()
	fmt.Printf("GRADE REPORT --- %d STUDENTS FOUND IN FILE\n", len(students))
	fmt.Printf("TEST WEIGHT: %.1f%%\n", testWeight)
	fmt.Printf("HOMEWORK WEIGHT: %.1f%%\n", homeworkWeight)
	fmt.Printf("CLASS TEST AVERAGE: %.1f\n", classTestAvg)
	fmt.Printf("CLASS HOMEWORK AVERAGE: %.1f\n", classHomeworkAvg)
	fmt.Printf("OVERALL AVERAGE is %.1f\n\n", classAvg)

	fmt.Printf("%-20s : %8s %5s %12s %5s %10s\n",
		"STUDENT NAME",
		"TESTS",
		"",
		"HOMEWORKS",
		"",
		"AVG")

	fmt.Println("---------------------------------------------------------------------")

	for _, student := range students {

		hwAvg := average(student.Homework)
		testAvg := average(student.Tests)

		total := hwAvg*(homeworkWeight/100.0) + testAvg*(testWeight/100.0)

		name := fmt.Sprintf("%s, %s", student.LastName, student.FirstName)

		fmt.Printf("%-20s : %8.1f %5s %12.1f %5s %10.1f",
			name,
			testAvg,
			fmt.Sprintf("(%d)", len(student.Tests)),
			hwAvg,
			fmt.Sprintf("(%d)", len(student.Homework)),
			total,
		)

		if len(student.Homework) < maxHomework {
			fmt.Print(" ** may be missing a homework **")
		}
		if len(student.Tests) < maxTests {
			fmt.Print(" ** may be missing a test **")
		}

		fmt.Println()
	}

	fmt.Println("---------------------------------------------------------------------")
	fmt.Println("\nEnd of Program 1")

}

// parseScores() converts a line of scores into an integer slice.
//
// This helper function accepts one line of text from the input file, separates
// the values by whitespace, converts each value to an integer, and returns the
// completed score slice. If a score cannot be converted, it returns an error.
//
// Return Types: []int, error
func parseScores(line string) ([]int, error) {
	fields := strings.Fields(line)

	scores := make([]int, 0, len(fields))

	for _, f := range fields {
		n, err := strconv.Atoi(f)
		if err != nil {
			return nil, err
		}
		scores = append(scores, n)
	}

	return scores, nil
}

// average() calculates the average of an integer slice.
//
// This helper function accepts a slice of integer scores, adds all of the
// values together, and divides by the number of scores. It returns 0 when
// the slice is empty to avoid dividing by zero.
//
// Return Type: float64
func average(scores []int) float64 {
	if len(scores) == 0 {
		return 0
	}

	sum := 0
	for _, v := range scores {
		sum += v
	}

	return float64(sum) / float64(len(scores))
}
