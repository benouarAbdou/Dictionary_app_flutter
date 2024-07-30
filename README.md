# Dictionary App

This is a Flutter-based Dictionary App that provides English-to-English word definitions, phonetic transcriptions, and audio pronunciations. The app also includes a feature to fetch and display a random word periodically, with recent searches being stored and displayed.

## Features

1. **Random Word Fetching**:
   - The app fetches a random word every time the user open the app and displays its details.
   - Users can tap on the displayed random word to view detailed information about the word.

2. **Word Search**:
   - Users can search for any word using the search bar.
   - If a searched word is valid, its details are displayed; otherwise, an "Invalid word" toast message is shown.

3. **Word Details Page**:
   - Detailed information about a word is displayed, including definitions, phonetics, and audio pronunciation.
   - Users can listen to the pronunciation of the word by tapping on the audio icon.

4. **Recent Searches**:
   - The app keeps track of the last 5 searched words.
   - These recent searches are displayed on the home page and can be tapped to view their details again.

5. **Offline Database**:
   - The app uses SQLite for storing recent searches.
   - When a new word is searched, it is added to the database if it doesn't already exist.
   - If there are more than 5 recent searches, the oldest entries are removed to keep the database size manageable.

## Structure

### Main Components

1. **Main App (`main.dart`)**:
   - Initializes the application and sets up the theme.
   - Contains the `MyHomePage` widget which is the main screen of the app.

2. **Home Page (`MyHomePage`)**:
   - Displays the random word and recent searches.
   - Contains the search bar for word lookup.
   - Uses a `Skeletonizer` widget to show loading skeletons while data is being fetched.

3. **Word Details Page (`WordDetailsPage`)**:
   - Displays detailed information about a selected word.
   - Fetches word details from the dictionary API and saves it in the database if valid.

4. **Database Helper (`SqlDb`)**:
   - Handles all SQLite database operations.
   - Manages saving, updating, reading, and deleting recent searches.

### Packages Used

- **fluttertoast**: For displaying toast messages.
- **http**: For making HTTP requests to fetch random words and word details from the dictionary API.
- **skeletonizer**: For displaying loading skeletons while fetching data.
- **sqflite**: For SQLite database operations.
- **path**: For managing file paths in the database.
- **audioplayers**: For playing audio pronunciations of words.

### API Endpoints

1. **Random Word API**:
   - URL: `https://random-word-form.herokuapp.com/random/noun`
   - Method: GET
   - Response: A random noun in JSON format.

2. **Dictionary API**:
   - URL: `https://api.dictionaryapi.dev/api/v2/entries/en/{word}`
   - Method: GET
   - Response: Word details including phonetics, definitions, and audio URLs in JSON format.


## Future Enhancements

- Implement a feature to save favorite words.
- Add more detailed word information like synonyms, antonyms, and usage examples.
- Improve error handling and provide more user-friendly error messages.
- Implement a better UI/UX design.

## Conclusion

This Dictionary App is a simple and effective tool for learning new English words. With its offline capabilities and periodic random word fetching, it provides a great way to expand vocabulary.
