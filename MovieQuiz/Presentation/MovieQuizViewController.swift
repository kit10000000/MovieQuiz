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
    private var correctAnswers = 0
    private var isButtonsEnabled = true
    private var questionFactory: QuestionFactoryProtocol?
    private let alertPresenter = AlertPresenter()
    var statisticService: StatisticServiceProtocol = StatisticService()
    private let presenter = MovieQuizPresenter()

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        presenter.viewController = self
        
        setUpUI()
        
        activityIndicator.hidesWhenStopped = true
        showLoadingIndicator()

        questionFactory = QuestionFactory(moviesLoader: MoviesLoader(), delegate: self)
        questionFactory?.loadData()
    }

    // MARK: - IBActions
    @IBAction private func yesButtonClicked(_ sender: UIButton) {
        guard isButtonsEnabled else { return }
        isButtonsEnabled = false
        presenter.yesButtonClicked()
    }
    
    @IBAction private func noButtonClicked(_ sender: UIButton) {
        guard isButtonsEnabled else { return }
        isButtonsEnabled = false
        presenter.noButtonClicked()
    }



    // MARK: - QuestionFactoryDelegate
    func didReceiveNextQuestion(question: QuizQuestion?) {
        hideLoadingIndicator()
        presenter.didReceiveNextQuestion(question: question)
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

    func show(quiz step: QuizStepViewModel) {
        counterLabel.text = step.questionNumber
        textLabel.text = step.question
        imageView.image = UIImage(data: step.imageData) ?? UIImage()
    }

    func showAnswerResult(isCorrect: Bool) {
        if isCorrect {
            correctAnswers += 1
        }

        imageView.layer.borderWidth = 8
        imageView.layer.borderColor = isCorrect ? UIColor.ypGreen.cgColor : UIColor.ypRed.cgColor

        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { [weak self] in
            guard let self = self else { return }
            self.presenter.correctAnswers = self.correctAnswers
            self.presenter.questionFactory = self.questionFactory
            presenter.showNextQuestionOrResults()
        }
    }

    func show(quiz result: QuizResultsViewModel) {
        let alertModel = AlertModel(title: result.title, message: result.text, buttonText: result.buttonText) { [weak self] in
            guard let self = self else { return }
            self.restartGame()
        }
        alertPresenter.show(in: self, model: alertModel)
    }

    private func restartGame() {
        imageView.layer.borderWidth = 0
        presenter.resetQuestionIndex()
        correctAnswers = 0
        imageView.image = nil
        counterLabel.text = "\(presenter.getCurrentQuestionIndex())/\(presenter.questionsAmount)"
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
    
    func resetImageLayout() {
        imageView.layer.borderWidth = 0
        imageView.image = nil
        showLoadingIndicator()
    }
    
}
