/*
	Author: Joyce Woznica
	Course: IST659 M400
	Term:	Fall 2018
	Project: Horse Vaccination Project
	Task: Populate Horse table
*/

-- I will be providing an update statement for the Microchip value when
-- all horses have been microchipped in late November/early December to abide by the
-- United States Equestrian Federation microchipping rule. For now - a placeholder 
-- (hence, why not an identity) has been reflected with an integer value
-- Notice that there is no ID first column (HorseID) as this is an identity integer and
-- cannot be inserted
INSERT INTO Horse
	(Microchip, BarnName, ShowName, FoalDate, Breed, BarnID)
	VALUES
		('1', 'Berkeley', 'No Fault of Mine', '05/12/2008', 'Clyde/TB', 'NY1'),
		('2', 'Batman', 'Gotham', '01/20/2007', 'QH', 'NY1'),
		('3', 'Q', 'Dun Q', '05/02/2016', 'QH', 'NY1'),
		('4', 'Erin', 'Forever Eowyn', '04/15/2001', 'TB/QH', 'NY2'),
		('5', 'Chicago', 'Untouchable', '04/20/2007', 'CSH', 'NY2'),
		('6', 'Sully', 'Secret Decision', '07/02/2006', 'TB/Perch', 'CT1')

SELECT * from Horse	
	ORDER BY BarnID