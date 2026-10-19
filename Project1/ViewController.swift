import UIKit
import CoreData

class ViewController: UIViewController {

    // MARK: - Properties

    private let tableView = UITableView(frame: .zero, style: .insetGrouped)
    private var todos: [Item] = []

    private var context: NSManagedObjectContext {
        PersistenceController.shared.container.viewContext
    }

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()

        title = "Todos"
        view.backgroundColor = .systemBackground

        navigationItem.rightBarButtonItem = UIBarButtonItem(
            barButtonSystemItem: .add,
            target: self,
            action: #selector(addTodo)
        )

        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")

        view.addSubview(tableView)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])

        loadTodos()
    }

    // MARK: - Core Data

    private func loadTodos() {
        let request = NSFetchRequest<Item>(entityName: "Item")
        request.sortDescriptors = [NSSortDescriptor(key: "timestamp", ascending: false)]

        do {
            todos = try context.fetch(request)
            tableView.reloadData()
        } catch {
            print("Fetch failed: \(error)")
        }
    }

    private func save() {
        do {
            try context.save()
        } catch {
            print("Save failed: \(error)")
        }
    }

    // MARK: - Actions

    @objc private func addTodo() {
        let alert = UIAlertController(title: "New Todo", message: nil, preferredStyle: .alert)
        alert.addTextField { $0.placeholder = "What needs doing?" }

        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))

        alert.addAction(UIAlertAction(title: "Add", style: .default) { [weak self, weak alert] _ in
            guard let self,
                  let text = alert?.textFields?.first?.text?.trimmingCharacters(in: .whitespacesAndNewlines),
                  !text.isEmpty else { return }

            let todo = Item(context: self.context)
            todo.title = text
            todo.timestamp = Date()
            todo.isDone = false

            self.save()
            self.loadTodos()
        })

        present(alert, animated: true)
    }
}

// MARK: - UITableViewDataSource

extension ViewController: UITableViewDataSource {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        todos.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        let todo = todos[indexPath.row]

        var content = cell.defaultContentConfiguration()
        content.text = todo.title
        cell.contentConfiguration = content
        cell.accessoryType = todo.isDone ? .checkmark : .none

        return cell
    }
}

// MARK: - UITableViewDelegate

extension ViewController: UITableViewDelegate {

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)

        let todo = todos[indexPath.row]
        todo.isDone = !todo.isDone
        save()
        tableView.reloadRows(at: [indexPath], with: .automatic)
    }

    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        guard editingStyle == .delete else { return }

        context.delete(todos[indexPath.row])
        save()
        todos.remove(at: indexPath.row)
        tableView.deleteRows(at: [indexPath], with: .automatic)
    }
}
