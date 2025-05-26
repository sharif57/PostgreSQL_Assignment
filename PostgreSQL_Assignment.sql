CREATE DATABASE conservation_db;

CREATE TABLE rangers (
    ranger_id SERIAL PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    region VARCHAR(100) NOT NULL
);

CREATE TABLE species (
    species_id SERIAL PRIMARY KEY,
    common_name VARCHAR(100) NOT NULL,
    scientific_name VARCHAR(100) NOT NULL,
    discovery_date DATE NOT NULL,
    conservation_status VARCHAR(50) NOT NULL CHECK (conservation_status IN ('Endangered', 'Vulnerable', 'Historic'))
);

CREATE TABLE sightings (
    sighting_id SERIAL PRIMARY KEY,
    ranger_id INT NOT NULL,
    species_id INT NOT NULL,
    location VARCHAR(100) NOT NULL,
    sighting_time TIMESTAMP NOT NULL,
    notes TEXT,
    FOREIGN KEY (ranger_id) REFERENCES rangers(ranger_id) ON DELETE CASCADE,
    FOREIGN KEY (species_id) REFERENCES species(species_id) ON DELETE CASCADE
);

INSERT INTO rangers (ranger_id, name, region) VALUES
(1, 'Ayesha Begum', 'Sundarbans'),
(2, 'Rahim Khan', 'Chittagong Hill Tracts'),
(3, 'Fatima Rahman', 'Lawachara National Park');

INSERT INTO species (species_id, common_name, scientific_name, discovery_date, conservation_status) VALUES
(1, 'Royal Bengal Tiger', 'Panthera tigris tigris', '1758-01-01', 'Endangered'),
(2, 'Hoolock Gibbon', 'Hoolock hoolock', '1771-01-01', 'Endangered'),
(3, 'Ganges River Dolphin', 'Platanista gangetica', '1801-01-01', 'Endangered'),
(4, 'Asian Elephant', 'Elephas maximus indicus', '1758-01-01', 'Endangered');

INSERT INTO sightings (sighting_id, species_id, ranger_id, location, sighting_time, notes) VALUES
(1, 1, 1, 'Dublar Char', '2024-05-10 07:45:00', 'Captured on camera trap near mangrove'),
(2, 2, 2, 'Sangu Reserve Forest', '2024-05-12 16:20:00', 'Young gibbon observed in tree canopy'),
(3, 3, 3, 'Lawachara Stream', '2024-05-15 09:10:00', 'Dolphin seen surfacing in stream'),
(4, 1, 2, 'Hiron Pass', '2024-05-18 18:30:00', NULL);

-- Problem 1: Register a new ranger with Bangladeshi name and region
INSERT INTO rangers (name, region) VALUES ('Mahmud Hasan', 'Madhupur National Park');

-- Problem 2: Count unique species ever sighted
SELECT COUNT(DISTINCT species_id) AS unique_species_count
FROM sightings;

-- Problem 3: Find sightings where location includes "Pass"
SELECT *
FROM sightings
WHERE location LIKE '%Pass%';

-- Problem 4: List each ranger's name and total sightings
SELECT r.name, COUNT(s.sighting_id) AS total_sightings
FROM rangers r
LEFT JOIN sightings s ON r.ranger_id = s.ranger_id
GROUP BY r.name
ORDER BY r.name;

-- Problem 5: List species never sighted
SELECT common_name
FROM species
WHERE species_id NOT IN (SELECT species_id FROM sightings);

-- Problem 6: Show the most recent 2 sightings
SELECT sp.common_name, s.sighting_time, r.name
FROM sightings s
JOIN species sp ON s.species_id = sp.species_id
JOIN rangers r ON s.ranger_id = r.ranger_id
ORDER BY s.sighting_time DESC
LIMIT 2;

-- Problem 7: Update species discovered before 1800 to 'Historic'
UPDATE species
SET conservation_status = 'Historic'
WHERE discovery_date < '1800-01-01';

-- Problem 8: Label each sighting's time of day
SELECT sighting_id,
       CASE
           WHEN EXTRACT(HOUR FROM sighting_time) < 12 THEN 'Morning'
           WHEN EXTRACT(HOUR FROM sighting_time) >= 12 AND EXTRACT(HOUR FROM sighting_time) < 17 THEN 'Afternoon'
           ELSE 'Evening'
       END AS time_of_day
FROM sightings
ORDER BY sighting_id;

-- Problem 9: Delete rangers with no sightings
DELETE FROM rangers
WHERE ranger_id NOT IN (SELECT ranger_id FROM sightings);