import UIKit

final class MovieQuizViewController: UIViewController, QuestionFactoryDelegate {

    // MARK: - IBOutlets
    @IBOutlet weak private var imageView: UIImageView!
    @IBOutlet weak private var counterLabel: UILabel!
    @IBOutlet weak private var textLabel: UILabel!
    @IBOutlet weak private var yesButton: UIButton!
    @IBOutlet weak private var noButton: UIButton!
    @IBOutlet weak private var activityIndicator: UIActivityIndicatorView!

    // MARK: - Private Properties
    private var currentQuestionIndex = 0
    private var correctAnswers = 0
    private var isButtonsEnabled = true
    private let questionsAmount: Int = 10
    private var questionFactory: QuestionFactoryProtocol?
    private var currentQuestion: QuizQuestion?
    private let alertPresenter = AlertPresenter()
    private var statisticService: StatisticServiceProtocol = StatisticService()

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpUI()
        
        activityIndicator.hidesWhenStopped = true
        showLoadingIndicator()

        questionFactory = QuestionFactory(moviesLoader: MoviesLoader(), delegate: self)
        questionFactory?.loadData()
    }

    // MARK: - IBActions
    @IBAction private func noButtonClicked(_ sender: UIButton) {
        guard isButtonsEnabled else { return }
        isButtonsEnabled = false
        guard let currentQuestion else { return }
        showAnswerResult(isCorrect: !currentQuestion.correctAnswer)
    }

    @IBAction private func yesButtonClicked(_ sender: UIButton) {
        guard isButtonsEnabled else { return }
        isButtonsEnabled = false
        guard let currentQuestion else { return }
        showAnswerResult(isCorrect: currentQuestion.correctAnswer)
    }

    // MARK: - QuestionFactoryDelegate
    func didReceiveNextQuestion(question: QuizQuestion?) {
        hideLoadingIndicator()
        guard let question else { return }

        currentQuestion = question
        let viewModel = convert(model: question)

        DispatchQueue.main.async { [weak self] in
            self?.show(quiz: viewModel)
        }
    }

    func didLoadDataFromServer() {
        hideLoadingIndicator()
        questionFactory?.requestNextQuestion()
    }

    func didFailToLoadData(with error: Error) {
        showNetworkError(message: error.localizedDescription)
    }

    // MARK: - Private Methods
    private func setUpUI() {
        imageView.layer.cornerRadius = 20
        imageView.layer.masksToBounds = true
        yesButton.layer.cornerRadius = 15
        yesButton.layer.masksToBounds = true
        noButton.layer.cornerRadius = 15
        noButton.layer.masksToBounds = true
    }

    private func convert(model: QuizQuestion) -> QuizStepViewModel {
        QuizStepViewModel(
            image: UIImage(data: model.imageData) ?? UIImage(),
            question: model.text,
            questionNumber: "\(currentQuestionIndex + 1)/\(questionsAmount)"
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

        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { [weak self] in
            guard let self = self else { return }
            self.showNextQuestionOrResults()
        }
    }

    private func showNextQuestionOrResults() {
        if currentQuestionIndex == questionsAmount - 1 {
            statisticService.store(correct: correctAnswers, total: questionsAmount)

            let bestGame = statisticService.bestGame
            let text = """
                Ваш результат: \(correctAnswers)/\(questionsAmount)
                Количество сыгранных квизов: \(statisticService.gamesCount)
                Рекорд: \(bestGame.correct)/\(bestGame.total) (\(bestGame.date.dateTimeString))
                Средняя точность: \(String(format: "%.2f", statisticService.totalAccuracy))%
                """

            let viewModel = QuizResultsViewModel(
                title: "Этот раунд окончен!",
                text: text,
                buttonText: "Сыграть ещё раз"
            )
            show(quiz: viewModel)
        } else {
            imageView.layer.borderWidth = 0
            currentQuestionIndex += 1
            imageView.image = nil
            showLoadingIndicator()
            questionFactory?.requestNextQuestion()
        }
    }

    private func show(quiz result: QuizResultsViewModel) {
        let alertModel = AlertModel(title: result.title, message: result.text, buttonText: result.buttonText) { [weak self] in
            guard let self = self else { return }
            self.restartGame()
        }
        alertPresenter.show(in: self, model: alertModel)
    }

    private func restartGame() {
        imageView.layer.borderWidth = 0
        currentQuestionIndex = 0
        correctAnswers = 0
        imageView.image = nil
        counterLabel.text = "\(currentQuestionIndex)/\(questionsAmount)"
        showLoadingIndicator()
        questionFactory?.requestNextQuestion()
    }

    private func showLoadingIndicator() {
        activityIndicator.startAnimating()
        isButtonsEnabled = false
    }

    private func hideLoadingIndicator() {
        activityIndicator.stopAnimating()
        isButtonsEnabled = true
    }

    private func showNetworkError(message: String) {
        hideLoadingIndicator()

        let model = AlertModel(title: "Ошибка", message: message, buttonText: "Попробовать еще раз") { [weak self] in
            guard let self = self else { return }
            self.showLoadingIndicator()
            self.questionFactory?.loadData()
        }

        alertPresenter.show(in: self, model: model)
    }
}
