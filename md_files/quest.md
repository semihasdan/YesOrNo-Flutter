The Master Prompt for "Yes Or No" Game Development
(Copy and paste this entire text into your AI coding model)
ROLE & GOAL
You are an expert senior frontend developer specializing in creating sleek, modern, and highly interactive applications using React. Your mission is to generate the complete frontend scaffolding for a new mobile-first web application, a competitive deduction game called "Yes Or No". Your output must be production-quality, well-structured, and perfectly aligned with the detailed design system provided.
PROJECT CONTEXT: "YES OR NO" - THE GAME
"Yes Or No" is a 1v1, real-time, turn-based deduction game with a futuristic, premium aesthetic. The core concept is a "cerebral battlefield" where players must deduce a secret word faster than their opponent. The gameplay is defined by tension, speed, and efficiency.
Core Loop: Each round is 10 seconds. Both players simultaneously type and submit a "Yes/No" question. Once the timer ends, both questions are revealed, and the answers ("YES" or "NO") are displayed visually through color.
Dynamic Scoring: A "Bounty" of points is available to the winner. This bounty decreases after every round, rewarding players who can solve the puzzle with fewer questions.
Winning: A player wins by correctly using the "Make Final Guess" feature at any time.
CORE PRINCIPLES & TECHNICAL CONSTRAINTS
Architecture: You MUST use React.js. Structure the code using modern best practices, including a component-based architecture. Adhere strictly to Object-Oriented Programming (OOP) principles where applicable (e.g., reusable components as "classes" or "blueprints" of UI).
Styling: You will use Styled-Components. This is non-negotiable. All styles must be encapsulated within their respective components. A global style file should be used for base styles, fonts, and resets.
Functionality - PROTOTYPE MODE: This is a UI/UX prototype.
Game logic buttons (e.g., "Ask", "Make Final Guess") should be visually complete but only execute a console.log indicating the action (e.g., console.log('Final Guess Submitted')).
Navigation buttons (e.g., going from Home to the Game Room, opening modals) MUST be fully functional. Use react-router-dom for navigation.
Immutability: State management should follow immutability principles. For this prototype, React's built-in useState and useContext hooks are sufficient.
Responsiveness: The design must be mobile-first, ensuring a flawless experience on smartphone screen sizes.
DESIGN SYSTEM & STYLE GUIDE REFERENCE
THIS IS THE MOST CRITICAL INSTRUCTION. I have provided a comprehensive style guide and visual mockups in a local directory: src/styles/. This directory contains style-guide.html and image assets (mockup-home.png, mockup-game.png, mockup-modal.png). You are to act as if you have full access to and have completely understood these files. Your generated UI MUST be a pixel-perfect re-creation of the aesthetic defined therein.
Key Design Tokens (extracted from the style guide):
Background: A blurred, soft gradient from warm amber (#FFB74D) to cool cerulean blue (#4FC3F7).
Primary Panel Style (Glassmorphism): Semi-transparent panels (rgba(20, 20, 30, 0.7)), with a backdrop-filter: blur(15px), rounded corners (16px), and a subtle white border (1px solid rgba(255, 255, 255, 0.1)).
Primary Accent (Cyan): #00FFFF. Used for primary actions. Features a prominent box-shadow: 0 0 25px #00FFFF;.
Secondary Accent (Magenta): #FF00FF. Used for secondary actions. Features a more subtle box-shadow: 0 0 15px #FF00FF;.
Tertiary Accent (Gold): #FFD700. Reserved for the "Make Final Guess" button. box-shadow: 0 0 20px #FFD700;.
Feedback Colors:
YES Green: #00FF7F (SpringGreen)
NO Red: #FF4136 (Crimson)
Typography:
Font Family: 'Poppins', sans-serif. Import this from Google Fonts in index.html.
Body Text: color: #F5F5F5;
Headings: color: #FFFFFF; font-weight: 600;
APPLICATION STRUCTURE & SCREEN-BY-SCREEN REQUIREMENTS
Generate the following file structure and component logic:


1. SplashScreen.js
Purpose: The initial loading screen.
UI: Display the game's minimalist 'Y/N' logo in the center with a cyan/magenta glow. No buttons.
Logic: After 3 seconds, automatically navigate the user to /home.
2. HomeScreen.js
Purpose: The main menu.
UI:
A main Glassmorphism panel in the center.
A header showing the player's avatar, username, and their RankIcon component (e.g., show the "Processor" rank icon as a default).
A primary glowing cyan "Quick Match" button.
A secondary vibrant magenta "Private Room" button.
Logic:
"Quick Match" navigates to /game.
"Private Room" opens the PrivateRoomModal.
3. PrivateRoomModal.js (Component)
Purpose: To create or join a private game. This modal is displayed over the HomeScreen.
UI: Exactly as seen in the style-guide.html and mockup-modal.png. A Glassmorphism panel with a "Create Room" (cyan) button, a text input for a room code, and a "Join" (magenta) button.
Logic:
"Create Room" navigates to /lobby.
"Join" button logs the entered code and navigates to /lobby.
4. LobbyScreen.js
Purpose: Waiting screen for a private match.
UI: A Glassmorphism panel showing a large, glowing Room Code (e.g., "KRTN5"). Displays two player slots, one filled, one "Waiting...". A "Start Game" button (cyan) is visible but disabled until a second player joins (for this prototype, it is always disabled).
Logic: A "Back" button navigates to /home.
5. GameRoom.js
Purpose: The main gameplay screen. This is the most complex component.
UI:
A vertical split-screen layout. Top for Player 1, bottom for Player 2.
Central Countdown Timer: A large, holographic-style timer that counts down from 10. The glow should intensify or change color as it nears 0.
Bounty Display: At the very top, "Bounty: 100 PTS".
Player Zones: Each zone has the player's info and a list of their asked questions. Each question is a Glassmorphism panel. Initially, they are neutral. After a round, they are permanently colored green for YES or red for NO.
Action Bar (bottom): A text input field and a "SUBMIT" button (cyan). The "MAKE FINAL GUESS" button (gold) is always present and distinct.
Logic: For this prototype, clicking "SUBMIT" should add a hardcoded question to the player's list and change its color to green or red randomly after a 1-second delay to simulate the opponent's turn.
6. GameOverModal.js (Component)
Purpose: Shown at the end of a match.
UI: A Glassmorphism modal appearing over the GameRoom. It displays "YOU WIN!" or "YOU LOSE!" in a large font. It shows the secret word. A "Play Again" button (cyan) and a "Back to Menu" button (magenta).
Logic:
"Play Again" logs to console and closes the modal (restarting the game state visually).
"Back to Menu" navigates to /home.
FINAL INSTRUCTIONS
Begin by setting up the main router in App.js and creating the GlobalStyles.js file based on the design tokens. Then, create each page and component methodically, ensuring perfect adherence to the design guide in src/styles/. Comment your code where the logic is complex. Provide a basic README.md explaining how to run the project.
