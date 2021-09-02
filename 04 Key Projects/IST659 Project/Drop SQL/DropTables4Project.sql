/*
	Author: Joyce Woznica
	Course: IST659 M400
	Term:	Fall 2018
	Project: Horse Vaccination Project
	Task: Drop all tables
*/

-- To drop tables, you need to drop in a specific order:
DROP TABLE HorseVaccine
DROP TABLE Vaccine
DROP TABLE Horse
DROP TABLE Barn
DROP TABLE Vet
DROP TABLE Clinic

-- This enables the dependencies to be handled when the tables are dropped
-- Then the Create statements can be re-run in the same order as they appear in the SQL file
