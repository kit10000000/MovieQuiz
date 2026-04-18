import UIKit

final class MovieQuizViewController: UIViewController, MovieQuizViewControllerProtocol {

    // MARK: - IBOutlets
    @IBOutlet weak private var imageView: UIImageView!
    @IBOutlet weak private var counterLabel: UILabel!
    @IBOutlet weak private var textLabel: UILabel!
    @IBOutlet weak private var yesButton: UIButton!
    @IBOutlet weak private var noButton: UIButton!
    @IBOutlet weak private var activityIndicator: UIActivityIndicatorView!

    // MARK: - Private Properties
    private var isButtonsEnabled = true
    private let alertPresenter = AlertPresenter()
    private var presenter: MovieQuizPresenter?

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        presenter = MovieQuizPresenter(viewController: self)
        setUpUI()
        activityIndicator.hidesWhenStopped = true
        showLoadingIndicator()
    }

    // MARK: - IBActions
    @IBAction private func yesButtonClicked(_ sender: UIButton) {
        guard isButtonsEnabled else { return }
        isButtonsEnabled = false
        presenter?.yesButtonClicked()
    }

    @IBAction private func noButtonClicked(_ sender: UIButton) {
        guard isButtonsEnabled else { return }
        isButtonsEnabled = false
        presenter?.noButtonClicked()
    }

    // MARK: - Methods
    func show(quiz step: QuizStepViewModel) {
        counterLabel.text = step.questionNumber
        textLabel.text = step.question
        imageView.image = UIImage(data: step.imageData) ?? UIImage()
    }

    func highlightImageBorder(isCorrectAnswer: Bool) {
        imageView.layer.masksToBounds = true
        imageView.layer.borderWidth = 8
        imageView.layer.borderColor = isCorrectAnswer ? UIColor.ypGreen.cgColor : UIColor.ypRed.cgColor
    }

    func show(quiz result: QuizResultsViewModel) {
        let alertModel = AlertModel(title: result.title, message: result.text, buttonText: result.buttonText) { [weak self] in
            guard let self else { return }
            presenter?.restartGame()
        }
        alertPresenter.show(in: self, model: alertModel)
    }

    func showLoadingIndicator() {
        activityIndicator.startAnimating()
        isButtonsEnabled = false
    }

    func hideLoadingIndicator() {
        activityIndicator.stopAnimating()
        isButtonsEnabled = true
    }

    func showNetworkError(message: String) {
        hideLoadingIndicator()

        let model = AlertModel(title: "Ошибка", message: message, buttonText: "Попробовать еще раз") { [weak self] in
            guard let self else { return }
            presenter?.reloadGame()
        }

        alertPresenter.show(in: self, model: model)
    }

    func resetImageLayout() {
        imageView.layer.borderWidth = 0
        imageView.image = nil
        showLoadingIndicator()
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
}
