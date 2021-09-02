/*
	Author: Joyce Woznica
	Course: IST659 M400
	Term:	Fall 2018
	Project: Horse Vaccination Project
	Task: Creation of Tables for Horse Vaccine Database
*/
-- Creating the Table for Clinic
-- ClinicID is a manufactured unique ID that I created as I know there will only be handful of Equine Clinics
-- that we will use for vaccines
-- It is important that we have an address (hence, not null), city, state and zip for each clinic as well as 
-- their phone number
CREATE TABLE Clinic (
	-- Columns for the Clinic table
	ClinicID varchar(3) not null,
	ClinicName varchar(40) not null,
	WebSiteURL varchar(60),
	Phone varchar(10) not null,
	StreetAddress varchar(65) not null,
	City varchar(25) not null,
	StateAbbr varchar(2) not null,
	Zip varchar(6) not null,
	-- Constraints on the Clinic Table
	-- This indicates that the ClinicID will be our primary key which is used as a foreign key in other tables
	CONSTRAINT PK_ClinicID PRIMARY KEY (ClinicID)
)
-- End Creating Clinic Table

-- Creating the Table for Vet
-- I could have created a way to automatically create the vet ID from the ClinicID and the next available number
-- however, I know each clinic never has more than 9 vets - most of 2 or 3.
-- The only required informatino is the VetID (unique primary key) and the First and Last Name
-- There is a not null foreign key to associate this vet with one and only one Clinic
CREATE TABLE Vet (
	-- Columns for the Vet table
	VetID varchar(4) not null,
	FirstName varchar(20) not null,
	LastName varchar(20) not null,
	LicenseNumber varchar(20),
	CellPhone varchar(10),
	ClinicID varchar(3) not null,
	-- Constraints on the Vet Table
	CONSTRAINT PK_VetID PRIMARY KEY (VetID),
	CONSTRAINT FK1_Vet FOREIGN KEY (ClinicID) REFERENCES Clinic(ClinicID)
)
-- End Creating Vet Table

-- Creating the Table for Barn
-- BARN ID is a unique abbrevation for a barn (sharing its state location as well).
-- It is a primary key. All other information is mandatory (hence, not null)
CREATE TABLE Barn (
	-- Columns for the Barn table
	BarnID varchar(3) not null,
	Name varchar(60) not null,
	StreetAddress varchar(65) not null,
	City varchar(25) not null,
	StateAbbr varchar(2) not null,
	Zip varchar(6) not null,
	Phone varchar(10) not null,
	-- Constraints on the Clinic Table
	CONSTRAINT PK_BarnID PRIMARY KEY (BarnID)
)
-- End Creating BarnTable

-- Creating the Table for Horse
-- Note: the Microchip is a varchar(30) to accomodate the upcoming chips for the
-- the United States Equestrian Federation ruling for all horses to be microchipped by 2019
CREATE TABLE Horse (
	-- Columns for the Horse table
	HorseID int identity not null,
	Microchip varchar(30) not null,
	BarnName varchar(20) not null,
	ShowName varchar(35) not null,
	FoalDate date not null,
	Breed varchar(20) not null,
	BarnID varchar(3) not null,
	-- Constraints on the Horse table
	CONSTRAINT PK_HorseID PRIMARY KEY (HorseID),
	CONSTRAINT FK1_Horse FOREIGN KEY (BarnID) REFERENCES Barn(BarnID)
)
-- End Creating Horse Table

-- Creating the Table for Vaccine
-- the Vaccine table is simple, just the name and cycle - which now is only Annual.
-- I could have added complexity by have a Cycle table with "Annual", "SemiAnnual", "Quarterly", but most vaccines
-- are annual, so it seemed overkill
-- the VaccineID is unique (identity) and also the primary key. All fields are mandatory.
CREATE TABLE Vaccine (
	-- Columns for the Vaccine table
	VaccineID int identity not null,
	Name varchar(20) not null,
	Cycle varchar(15) not null,
	-- Constraints on the Vaccine table
	CONSTRAINT PK_VaccineID PRIMARY KEY (VaccineID)
)
-- End Creating Vaccine Table

-- Creating the Table for HorseVaccine
-- This table is the one that has all the foreign keys for: 
--      Microchip (Horse), VaccineID (Vaccine), VetID (Vet)
-- This is the table that links each horse to its vaccines on which date by which vet
CREATE TABLE HorseVaccine (
	-- Columns for the HorseVaccine table
	HorseVaccineID int identity not null,
	HorseID int not null,
	VaccineID int not null,
	VaccineBatch varchar(20),
	VaccineDate date not null,
	--- This should be created based on the value of VaccineDate (if annual, then add 12 months, etc.)
	--- However, we have a procedure to do that later 
	VaccineScheduledDate date,
	VaccineCost decimal(6,2) not null,
	VetID varchar(4) not null,
	-- Constraints on the HorseVaccine table
	CONSTRAINT PK_HorseVaccineID PRIMARY KEY (HorseVaccineID),
	CONSTRAINT FK1_HorseVaccine FOREIGN KEY (HorseID) REFERENCES Horse(HorseID),
	CONSTRAINT FK2_HorseVaccine FOREIGN KEY (VaccineID) REFERENCES Vaccine(VaccineID),
	CONSTRAINT FK3_HorseVaccine FOREIGN KEY (VetID) REFERENCES Vet(VetID)
)
-- End Creating HorseVaccine Table