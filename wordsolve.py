import random
import requests

def fetch_wordlist():
    response = requests.get("https://api.wordnik.com/v4/words.json/randomWords",
                            params={"minLength": 5, "maxLength": 5, "limit": 100, "api_key": "YOUR_API_KEY_HERE"})
    words = [word["word"].lower() for word in response.json()]
    return words

def get_feedback(target_word, guessed_word):
    feedback = ''
    for i in range(len(target_word)):
        if guessed_word[i] == target_word[i]:
            feedback += guessed_word[i].upper()
        elif guessed_word[i] in target_word:
            feedback += guessed_word[i]
        else:
            feedback += '-'
    return feedback

def pre_process_words(possible_words):
    feedback_dict = {}
    for word in possible_words:
        feedback = ''.join(sorted(word))
        if feedback not in feedback_dict:
            feedback_dict[feedback] = []
        feedback_dict[feedback].append(word)
    return feedback_dict

def filter_words(feedback_dict, guessed_word, feedback):
    possible_words = feedback_dict.get(''.join(sorted(guessed_word)), [])
    filtered_words = []
    for word in possible_words:
        if get_feedback(word, guessed_word) == feedback:
            filtered_words.append(word)
    return filtered_words

def prioritize_guesses(feedback_dict, guessed_word, feedback):
    possible_feedbacks = [get_feedback(word, guessed_word) for word in feedback_dict[''.join(sorted(guessed_word))]]
    best_feedback = max(set(possible_feedbacks), key=possible_feedbacks.count)
    return [word for word in feedback_dict[''.join(sorted(guessed_word))] if get_feedback(word, guessed_word) == best_feedback]

def wordle_solver():
    possible_words = fetch_wordlist()
    feedback_dict = pre_process_words(possible_words)
    target_word = random.choice(possible_words)

    attempts = 0
    guessed_word = ''
    feedback = '-----'
    print("Target word:", target_word)

    while feedback != '*****':
        attempts += 1
        print("\nAttempt:", attempts)
        print("Guessed word:", guessed_word)
        print("Feedback:", feedback)

        possible_words = filter_words(feedback_dict, guessed_word, feedback)
        possible_words = prioritize_guesses(feedback_dict, guessed_word, feedback)

        guessed_word = random.choice(possible_words)

        feedback = get_feedback(target_word, guessed_word)

    print("\nWordle solved in", attempts, "attempts!")
    print("Target word:", target_word)

if __name__ == "__main__":
    wordle_solver()
