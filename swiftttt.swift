import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    var window: UIWindow?
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        window = UIWindow(frame: UIScreen.main.bounds)
        let mainViewController = MoviesListViewController()
        let navigationController = UINavigationController(rootViewController: mainViewController)
        window?.rootViewController = navigationController
        window?.makeKeyAndVisible()
        return true
    }
}
import UIKit

class MoviesListViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    private var movies: [Movie] = []
    private let tableView = UITableView()

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Trending Movies"
        view.addSubview(tableView)
        tableView.frame = view.bounds
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        fetchTrendingMovies()
    }

    func fetchTrendingMovies() {
        let urlString = "https://api.themoviedb.org/3/discover/movie?api_key=c9856d0cb57c3f14bf75bdc6c063b8f3"
        guard let url = URL(string: urlString) else { return }
        let task = URLSession.shared.dataTask(with: url) { (data, response, error) in
            guard let data = data else { return }
            do {
                let result = try JSONDecoder().decode(MovieResponse.self, from: data)
                self.movies = result.results
                DispatchQueue.main.async {
                    self.tableView.reloadData()
                }
            } catch {
                print(error)
            }
        }
        task.resume()
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return movies.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        let movie = movies[indexPath.row]
        cell.textLabel?.text = movie.title
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let movie = movies[indexPath.row]
        let detailVC = MovieDetailViewController(movie: movie)
        navigationController?.pushViewController(detailVC, animated: true)
    }
}

struct MovieResponse: Codable {
    let results: [Movie]
}

struct Movie: Codable {
    let title: String
    let id: Int
    // Add other necessary fields
}
import UIKit

class MovieDetailViewController: UIViewController {
    private let movie: Movie
    private let titleLabel = UILabel()
    private let posterImageView = UIImageView()

    init(movie: Movie) {
        self.movie = movie
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        title = movie.title
        view.backgroundColor = .white
        setupUI()
        fetchMovieDetails()
    }

    func setupUI() {
        // Set up UI components
        view.addSubview(titleLabel)
        view.addSubview(posterImageView)
        // Add constraints and customization
    }

    func fetchMovieDetails() {
        let urlString = "https://api.themoviedb.org/3/movie/\(movie.id)?api_key=c9856d0cb57c3f14bf75bdc6c063b8f3"
        guard let url = URL(string: urlString) else { return }
        let task = URLSession.shared.dataTask(with: url) { (data, response, error) in
            guard let data = data else { return }
            do {
                let result = try JSONDecoder().decode(MovieDetail.self, from: data)
                DispatchQueue.main.async {
                    self.updateUI(with: result)
                }
            } catch {
                print(error)
            }
        }
        task.resume()
    }

    func updateUI(with details: MovieDetail) {
        titleLabel.text = details.title
        // Load and set the poster image
        let posterPath = "https://image.tmdb.org/t/p/w500/\(details.posterPath)"
        if let url = URL(string: posterPath) {
            URLSession.shared.dataTask(with: url) { (data, response, error) in
                if let data = data {
                    DispatchQueue.main.async {
                        self.posterImageView.image = UIImage(data: data)
                    }
                }
            }.resume()
        }
    }
}

struct MovieDetail: Codable {
    let title: String
    let posterPath: String
    // Add other necessary fields
}
