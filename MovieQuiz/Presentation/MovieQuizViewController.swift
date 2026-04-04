import UIKit

final class MovieQuizViewController: UIViewController {
    
    // MARK: - Properties
    private var currentQuestionIndex = 0
    private var correctAnswers = 0
    private let questions: [QuizQuestion] = [
        QuizQuestion(image: "The Godfather", text: "Рейтинг этого фильма больше чем 6?", correctAnswer: true),
        QuizQuestion(image: "The Dark Knight", text: "Рейтинг этого фильма больше чем 6?", correctAnswer: true),
        QuizQuestion(image: "Kill Bill", text: "Рейтинг этого фильма больше чем 6?", correctAnswer: true),
        QuizQuestion(image: "The Avengers", text: "Рейтинг этого фильма больше чем 6?", correctAnswer: true),
        QuizQuestion(image: "Deadpool", text: "Рейтинг этого фильма больше чем 6?", correctAnswer: true),
        QuizQuestion(image: "The Green Knight", text: "Рейтинг этого фильма больше чем 6?", correctAnswer: true),
        QuizQuestion(image: "Old", text: "Рейтинг этого фильма больше чем 6?", correctAnswer: false),
        QuizQuestion(image: "The Ice Age Adventures of Buck Wild", text: "Рейтинг этого фильма больше чем 6?", correctAnswer:false),
        QuizQuestion(image: "Tesla", text: "Рейтинг этого фильма больше чем 6?", correctAnswer: false),
        QuizQuestion(image: "Vivarium", text: "Рейтинг этого фильма больше чем 6?", correctAnswer: false)
    ]
    
    
    @IBOutlet weak private var imageView: UIImageView!
    @IBOutlet weak private var counterLabel: UILabel!
    @IBOutlet weak private var textLabel: UILabel!
    @IBOutlet weak private var yesButton: UIButton!
    @IBOutlet weak private var noButton: UIButton!
    
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpUI()
        show(quiz: convert(model: questions[currentQuestionIndex]))
    }
    
    // MARK: - Setup
    private func setUpUI()
    {
        imageView.layer.cornerRadius = 20
        imageView.layer.masksToBounds = true
        yesButton.layer.cornerRadius = 15
        yesButton.layer.masksToBounds = true
        noButton.layer.cornerRadius = 15
        noButton.layer.masksToBounds = true
    }
    
    // MARK: - Private Methods
    private func convert(model: QuizQuestion) -> QuizStepViewModel {
        QuizStepViewModel(
            image: UIImage(named: model.image) ?? UIImage(),
            question: model.text,
            questionNumber: "\(currentQuestionIndex + 1)/\(questions.count)"
        )
    }
    
    private func show(quiz step: QuizStepViewModel) {
        counterLabel.text = step.questionNumber
        textLabel.text = step.question
        imageView.image = step.image
    }
    
    private func showAnswerResult(isCorrect: Bool) {
        if isCorrect {
            correctAnswers += 1
        }
        
        imageView.layer.borderWidth = 8
        imageView.layer.borderColor = isCorrect ? UIColor.ypGreen.cgColor : UIColor.ypRed.cgColor
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            self.showNextQuestionOrResults()
        }
    }
    
    private func showNextQuestionOrResults() {
        if currentQuestionIndex == questions.count - 1 {
            let viewModel = QuizResultsViewModel(
                title: "Этот раунд окончен!",
                text: "Ваш результат \(correctAnswers)/\(questions.count)",
                buttonText: "Сыграть ещё раз"
            )
            show(quiz:viewModel)
        } else {
            imageView.layer.borderWidth = 0
            currentQuestionIndex += 1
            show(quiz: convert(model: questions[currentQuestionIndex]))
        }
        
    }
    
    private func show(quiz result: QuizResultsViewModel) {
        let alert = UIAlertController(
            title: result.title,
            message: result.text,
            preferredStyle: .alert)
        
        let action = UIAlertAction(title: result.buttonText, style: .default) { _ in
            self.imageView.layer.borderWidth = 0
            self.currentQuestionIndex = 0
            self.correctAnswers = 0
            self.show(quiz: self.convert(model: self.questions[self.currentQuestionIndex]))
        }
        
        alert.addAction(action)
        present(alert, animated: true, completion: nil)
    }
    
    // MARK: - Actions
    @IBAction private func noButtonClicked(_ sender: UIButton) {
        let currentQuestion = questions[currentQuestionIndex]
        showAnswerResult(isCorrect: !currentQuestion.correctAnswer)
    }
    
    @IBAction private func yesButtonClicked(_ sender: UIButton) {
        let currentQuestion = questions[currentQuestionIndex]
        showAnswerResult(isCorrect: currentQuestion.correctAnswer)
    }
    
    private struct QuizQuestion {
        let image: String
        let text: String
        let correctAnswer: Bool
    }


    private struct QuizStepViewModel {
        let image: UIImage
        let question: String
        let questionNumber: String
    }

    private struct QuizResultsViewModel {
        let title: String
        let text: String
        let buttonText: String
    }
}


