# Aplikacja Mocny Strzal

Aplikacja Koktajle to aplikacja mobilna napisana w Flutterze, która pozwala użytkownikom przeglądać i filtrować przepisy na koktajle. Użytkownicy mogą wyszukiwać koktajle według nazwy, kategorii lub zawartości alkoholu oraz uzyskać szczegółowe informacje na temat składników i sposobu przygotowania każdego koktajlu.

## Funkcje

### 1. Przegląd koktajli
Aplikacja umożliwia przeglądanie koktajli, wyświetlając listę dostępnych napojów z podstawowymi informacjami, takimi jak:
- Nazwa koktajlu
- Zdjęcie koktajlu

### 2. Wyświetlanie szczegółów koktajlu
Użytkownicy mogą kliknąć na wybrany koktajl, aby zobaczyć jego szczegóły, które obejmują:
- Kategorię
- Sposób podania
- Składniki z ich ilościami
- Instrukcje przygotowania
- Informację o zawartości alkoholu

### 3. Filtrowanie wyników
Aplikacja oferuje narzędzia filtrujące wyniki koktajli na podstawie:
- **Nazwa** - wyszukiwanie pełnotekstowe
- **Kategoria** - wybór kategorii z listy
- **Zawartość alkoholu** - możliwość wyboru między napojami alkoholowymi, bezalkoholowymi lub obu typami

### 4. Zastosowanie infinity scrolla
- Treści po dojechaniu na koniec strony ładują się aż do końca pozycji w menu.

## Instalacja

1. **Klonuj repozytorium**:
   ```bash
   git clone https://github.com/BombardierBulge/mocny_strzal.git

## Znane błędy
- Baza danych zawiera pliki o powtórzonych parametrach takich jak np. https://cocktails.solvro.pl/api/v1/ingredients?name=Soda%20water którę mają dwa występowania z innymi wartościami pól ale takimi samymi nazwami co może powodować dziwne wyszukiwania
- Po restarcie aplikacji dane wprowadzone w pole wyszukiwania zostają ale nie są one wyszukiwane przez program, dopiero po zmianie któregoś z filtrów albo po ponownym włączeniu dane znikają 