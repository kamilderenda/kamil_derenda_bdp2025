ZAD1. CREATE DATABASE firma;
ZAD2. CREATE SCHEMA ksiegowosc;

ZAD3.CREATE TABLE ksiegowosc.pracownicy (
    id_pracownika SERIAL PRIMARY KEY,
    imie VARCHAR(100),
    nazwisko VARCHAR(100),
    adres VARCHAR(150),
    telefon VARCHAR(50)
);

CREATE TABLE ksiegowosc.godziny (
    id_godziny SERIAL PRIMARY KEY,
    data DATE,
    liczba_godzin INT,
    id_pracownika INT REFERENCES ksiegowosc.pracownicy(id_pracownika) ON DELETE SET NULL
);

CREATE TABLE ksiegowosc.pensje (
    id_pensji SERIAL PRIMARY KEY,
    stanowisko VARCHAR(100),
    kwota DOUBLE PRECISION
);

CREATE TABLE ksiegowosc.premia (
    id_premii SERIAL PRIMARY KEY,
    rodzaj VARCHAR(200),
    kwota DOUBLE PRECISION
);

CREATE TABLE ksiegowosc.wynagrodzenie (
    id_wynagrodzenia SERIAL PRIMARY KEY,
    data DATE,
    id_pracownika INT REFERENCES ksiegowosc.pracownicy(id_pracownika) ON DELETE SET NULL,
    id_godziny INT REFERENCES ksiegowosc.godziny(id_godziny) ON DELETE SET NULL,
    id_pensji INT REFERENCES ksiegowosc.pensje(id_pensji) ON DELETE SET NULL,
    id_premii INT REFERENCES ksiegowosc.premia(id_premii) ON DELETE SET NULL
);

ZAD4.INSERT INTO ksiegowosc.pracownicy (imie, nazwisko, adres, telefon) VALUES
('Jan', 'Kowalski', 'Warszawa, ul. Długa 1', '500100001'),
('Anna', 'Nowak', 'Kraków, ul. Szkolna 2', '500100002'),
('Piotr', 'Zieliński', 'Gdańsk, ul. Morska 3', '500100003'),
('Ewa', 'Wiśniewska', 'Poznań, ul. Leśna 4', '500100004'),
('Krzysztof', 'Kamiński', 'Wrocław, ul. Wrzosowa 5', '500100005'),
('Monika', 'Jankowska', 'Łódź, ul. Piękna 6', '500100006'),
('Tomasz', 'Wójcik', 'Lublin, ul. Różana 7', '500100007'),
('Magdalena', 'Kaczmarek', 'Katowice, ul. Lipowa 8', '500100008'),
('Paweł', 'Mazur', 'Szczecin, ul. Brzozowa 9', '500100009'),
('Agnieszka', 'Lewandowska', 'Bydgoszcz, ul. Słoneczna 10', '500100010');

INSERT INTO ksiegowosc.pensje (stanowisko, kwota) VALUES
('Programista', 8000),
('Analityk', 7000),
('Rekruter', 6000),
('Administrator', 7500),
('Tester', 6500),
('Kierownik', 10000),
('Projektant', 7200),
('Specjalista HR', 6800),
('Finansista', 8500),
('Marketingowiec', 6300);

INSERT INTO ksiegowosc.premia (rodzaj, kwota) VALUES
('Premia kwartalna', 1200),
('Premia roczna', 2000),
('Premia za wydajność', 1500),
('Premia za projekt', 1000),
('Premia uznaniowa', 800),
('Premia świąteczna', 900),
('Premia motywacyjna', 1100),
('Premia projektowa', 1300),
('Premia specjalna', 1400),
('Premia jubileuszowa', 1000);

INSERT INTO ksiegowosc.godziny (data, liczba_godzin, id_pracownika) VALUES
('2025-10-01', 8, 1),
('2025-10-01', 7, 2),
('2025-10-01', 8, 3),
('2025-10-01', 6, 4),
('2025-10-01', 8, 5),
('2025-10-01', 7, 6),
('2025-10-01', 8, 7),
('2025-10-01', 6, 8),
('2025-10-01', 8, 9),
('2025-10-01', 7, 10);

INSERT INTO ksiegowosc.wynagrodzenie (data, id_pracownika, id_godziny, id_pensji, id_premii) VALUES
('2025-10-01', 1, 1, 1, 1),
('2025-10-01', 2, 2, 2, 2),
('2025-10-01', 3, 3, 3, 3),
('2025-10-01', 4, 4, 4, 4),
('2025-10-01', 5, 5, 5, 5),
('2025-10-01', 6, 6, 6, 6),
('2025-10-01', 7, 7, 7, 7),
('2025-10-01', 8, 8, 8, 8),
('2025-10-01', 9, 9, 9, 9),
('2025-10-01', 10, 10, 10, 10);

ZAD5.
  a)SELECT id_pracownika, nazwisko
FROM pracownicy
b)SELECT a.id_pracownika
FROM wynagrodzenie a 
LEFT JOIN pensje b ON a.id_pensji = b.id_pensji
WHERE b.kwota > 1000

c)SELECT w.id_pracownika
FROM ksiegowosc.wynagrodzenie w
JOIN ksiegowosc.pensje p ON w.id_pensji = p.id_pensji
WHERE w.id_premii IS NULL
  AND p.kwota > 2000;
d)SELECT imie, nazwisko
FROM ksiegowosc.pracownicy
WHERE imie LIKE 'J%';
e)SELECT imie, nazwisko
FROM ksiegowosc.pracownicy
WHERE nazwisko ILIKE '%n%'
  AND imie ILIKE '%a';
f)SELECT p.imie, p.nazwisko, 
       GREATEST(g.liczba_godzin - 160, 0) AS nadgodziny
FROM ksiegowosc.pracownicy p
JOIN ksiegowosc.godziny g ON p.id_pracownika = g.id_pracownika;
g)SELECT p.imie, p.nazwisko, pen.kwota
FROM ksiegowosc.pracownicy p
JOIN ksiegowosc.wynagrodzenie w ON p.id_pracownika = w.id_pracownika
JOIN ksiegowosc.pensje pen ON w.id_pensji = pen.id_pensji
WHERE pen.kwota BETWEEN 1500 AND 3000;
h)SELECT p.imie, p.nazwisko
FROM ksiegowosc.pracownicy p
JOIN ksiegowosc.godziny g ON p.id_pracownika = g.id_pracownika
JOIN ksiegowosc.wynagrodzenie w ON p.id_pracownika = w.id_pracownika
WHERE g.liczba_godzin > 160
  AND w.id_premii IS NULL;
i)SELECT p.imie, p.nazwisko, pen.kwota
FROM ksiegowosc.pracownicy p
JOIN ksiegowosc.wynagrodzenie w ON p.id_pracownika = w.id_pracownika
JOIN ksiegowosc.pensje pen ON w.id_pensji = pen.id_pensji
ORDER BY pen.kwota ASC;
j)SELECT p.imie, p.nazwisko, pen.kwota AS pensja, pr.kwota AS premia
FROM ksiegowosc.pracownicy p
JOIN ksiegowosc.wynagrodzenie w ON p.id_pracownika = w.id_pracownika
JOIN ksiegowosc.pensje pen ON w.id_pensji = pen.id_pensji
LEFT JOIN ksiegowosc.premia pr ON w.id_premii = pr.id_premii
ORDER BY pen.kwota DESC, pr.kwota DESC;
k)SELECT pen.stanowisko, COUNT(*) AS liczba_pracownikow
FROM ksiegowosc.wynagrodzenie w
JOIN ksiegowosc.pensje pen ON w.id_pensji = pen.id_pensji
GROUP BY pen.stanowisko;
l)SELECT AVG(pen.kwota) AS srednia_pensja,
       MIN(pen.kwota) AS minimalna_pensja,
       MAX(pen.kwota) AS maksymalna_pensja
FROM ksiegowosc.wynagrodzenie w
JOIN ksiegowosc.pensje pen ON w.id_pensji = pen.id_pensji
WHERE pen.stanowisko = 'Kierownik';
m)SELECT SUM(pen.kwota + COALESCE(pr.kwota, 0)) AS laczne_wynagrodzenie
FROM ksiegowosc.wynagrodzenie w
JOIN ksiegowosc.pensje pen ON w.id_pensji = pen.id_pensji
LEFT JOIN ksiegowosc.premia pr ON w.id_premii = pr.id_premii;
n)SELECT pen.stanowisko, SUM(pen.kwota + COALESCE(pr.kwota,0)) AS suma_wynagrodzen
FROM ksiegowosc.wynagrodzenie w
JOIN ksiegowosc.pensje pen ON w.id_pensji = pen.id_pensji
LEFT JOIN ksiegowosc.premia pr ON w.id_premii = pr.id_premii
GROUP BY pen.stanowisko;
o)SELECT pen.stanowisko, COUNT(w.id_premii) AS liczba_premii
FROM ksiegowosc.wynagrodzenie w
JOIN ksiegowosc.pensje pen ON w.id_pensji = pen.id_pensji
WHERE w.id_premii IS NOT NULL
GROUP BY pen.stanowisko;
u)DELETE FROM ksiegowosc.pracownicy
WHERE id_pracownika IN (
    SELECT w.id_pracownika
    FROM ksiegowosc.wynagrodzenie w
    JOIN ksiegowosc.pensje p ON w.id_pensji = p.id_pensji
    WHERE p.kwota < 1200
);

