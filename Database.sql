-- DO and AS 

	-- DO : used for an anonymous block, run this code once then throw away
		DO $$
		BEGIN
			RAISE NOTICE 'Hello';
		END;
		$$ LANGUAGE plpgsql;

	-- AS : used when creatinf a stored funciton procedure 
		CREATE FUNCTION hello()
		RETURNS TEXT
		AS $$
		BEGIN
			RETURN 'Hello';
		END;
		$$ LANGUAGE plpgsql;


--------------------------------------------------------------
-- Basic Block structure 
	DO $$
	DECLARE
		--variable datatype := value;
		first_name TEXT := 'John';
		age INT := 20;
	BEGIN
		-- executable code starts here
		RAISE NOTICE 'Name: %, Age: %',
			first_name,
			age;
	END;
	$$ LANGUAGE plpgsql

--------------------------------------------------------------
-- string concatenation, ||

DO $$
DECLARE
    first_name TEXT := 'John';
    last_name TEXT := 'Doe';
    full_name TEXT;

BEGIN
    full_name := first_name || ' ' || last_name;
    RAISE NOTICE 'Full Name: %',
        full_name;

END;
$$ LANGUAGE plpgsql;

--------------------------------------------------------------

-- Storing SQL result into variable SELECT INTO 
	DROP TABLE IF EXISTS students;

	CREATE TABLE students
	(
		student_id SERIAL PRIMARY KEY,
		name TEXT,
		age INT
	);


	INSERT INTO students(name, age)
	VALUES
	('John',20),
	('Mary',22);

	DO $$
	DECLARE
	-- variable to store result

    student_name TEXT;
    student_age INT;


	BEGIN
    -- SQL result goes into variables
		SELECT name, age 
		INTO student_name, student_age
		FROM students
		WHERE student_id = 1;
		-- find the student's whose stuent_id is 1, take their name and age and store them into variables 


		RAISE NOTICE
		'Student: %, Age: %',
		student_name,
		student_age;

	END;
	$$ LANGUAGE plpgsql;

--------------------------------------------------------------
--%ROWTYPE, sotre into the entire row
	DO $$

	DECLARE

	student_record students%ROWTYPE;

	BEGIN
		SELECT *
		INTO student_record
		FROM students
		WHERE student_id = 1;



		RAISE NOTICE
		'ID %, Name %, Age %',
		student_record.student_id,
		student_record.name,
		student_record.age;


	END;
	$$ LANGUAGE plpgsql;


--------------------------------------------------------------
--IF statements
DO $$

DECLARE

    age INT := 20;

BEGIN


    IF age < 13 THEN
        RAISE NOTICE 'Child';

    ELSIF age < 20 THEN
        RAISE NOTICE 'Teenager';

    ELSE
        RAISE NOTICE 'Adult';

    END IF;

END;

$$ LANGUAGE plpgsql;


--------------------------------------------------------------
--FUNCTIONS and PROCEDURE

