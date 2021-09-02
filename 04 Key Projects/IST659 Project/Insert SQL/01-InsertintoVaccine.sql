/*
	Author: Joyce Woznica
	Course: IST659 M400
	Term:	Fall 2018
	Project: Horse Vaccination Project
	Task: Populate the Vaccine table
*/
-- Enter Vaccines into Vaccine Table. Notice that there is a Potomac - Spring and a Potomac - Fall
-- for this project I did not start with having these as Semi-Annual, but intend to try to change that
-- and then have only one value for Potomac. 
INSERT INTO Vaccine
	(Name, Cycle)
	VALUES
		('E/W/T/Flu/Rhino', 'Annual'),
		('Potomac - Spring', 'Annual'),
		('Rabies', 'Annual'),
		('Coggins', 'Annual'),
		('West Nile', 'Annual'),
		('Strangles', 'Annual'),
		('Potomac - Fall', 'Annual'),
		('Flu/Rhino - Fall', 'Annual'),
		('Fecal', 'Annual'),
		('Lyme Titer', 'Annual')

SELECT * from Vaccine