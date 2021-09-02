/*
	Author: Joyce Woznica
	Course: IST659 M400
	Term:	Fall 2018
	Project: Horse Vaccination Project
	Task: Populate the Vet table
*/

-- In this case, I do not have all the license numbers or cell phones for these vets
INSERT into Vet
	(VetID, FirstName, LastName, LicenseNumber, CellPhone, ClinicID)
	VALUES
		('CTE1', 'Mike', 'Reilly', '', '', 'CTE'),
		('CTE2', 'Scott', 'Sears', '', '', 'CTE'),
		('ASC1', 'Douglas', 'Pierson', '011449-1 NYS', '', 'ASC'),
		('CTE3', 'Ginny', 'Williamson', '', '', 'CTE'),
		('SVP1', 'Hannah', 'Smith', '', '', 'SPV'),
		('LKW1', 'Joe', 'Jones', '', '', 'LKW')

SELECT * FROM Vet

