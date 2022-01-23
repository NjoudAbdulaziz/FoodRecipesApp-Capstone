//
//  SavedRecipeDetailsVC.swift
//  FoodRecipes
//
//  Created by Njoud Alrshidi on 26/05/1443 AH.
//

import UIKit
import CoreData
import SwiftMessages

class SavedRecipeDetailsVC : UIViewController {
    
    //MARK:-Outlets
    @IBOutlet weak var recipeBannerImageView: UIImageView!
    @IBOutlet weak var recipeTitleLabel: UILabel!
    @IBOutlet weak var youtubeButton: UIButton!
    @IBOutlet weak var savedButton: UIButton!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var webButton: UIButton!
    @IBOutlet weak var selectedSegment: UISegmentedControl!
    @IBOutlet weak var recipeInstrusctionsTextView: UITextView!
    @IBOutlet weak var IngredientsView: UIStackView!
    
    //MARK:-Properties
    var recipe:Recipe!
    var fetchedResultsController:NSFetchedResultsController<Ingredients>!
    let titleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.black]
    let selectedtitleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.white]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        guard let selectedRecipe = recipe else {
          return
        }
        savedButton.setTitle("Saved".localized, for: UIControl.State.selected)
        if #available(iOS 13.0, *) {
            savedButton.setImage(UIImage(systemName: "heart.fill"), for: UIControl.State.selected)
        } else {
            // Fallback on earlier versions  heart_filled
            savedButton.setImage(UIImage(named: "heart_filled"), for: UIControl.State.selected)
        }
        tableView.dataSource = self
        tableView.delegate = self
       
        selectedSegment.setTitleTextAttributes(titleTextAttributes, for: .normal)
        selectedSegment.setTitleTextAttributes(selectedtitleTextAttributes, for: .selected)
        populateRecipe(recipe: selectedRecipe)
        setUpFetchedResultsController()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setUpFetchedResultsController()
        tableView.reloadData()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        fetchedResultsController = nil
    }
    
    //Fetch All the Recipe Ingredients
    fileprivate func setUpFetchedResultsController() {
        let fetchRequest:NSFetchRequest<Ingredients> = Ingredients.fetchRequest()
        let predicate = NSPredicate(format: "recipe == %@", recipe)
        fetchRequest.predicate = predicate
        let sortDescriptor = NSSortDescriptor(key: "name", ascending: true)
        fetchRequest.sortDescriptors = [sortDescriptor]
        
        fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: DataController.shared.viewContext, sectionNameKeyPath: nil, cacheName: "\(String(describing: recipe.name!))-Ingredients")
        fetchedResultsController.delegate = self

        do {
            try fetchedResultsController.performFetch()
        } catch {
            fatalError("The fetch could not be performed: \(error.localizedDescription)")
        }
    }
    
    
    func populateRecipe(recipe:Recipe)  {
        savedButton.isSelected = true
        recipeTitleLabel.text = recipe.name
        self.navigationItem.title = recipe.area! + " - " + recipe.category!
        recipeBannerImageView.image = UIImage(data: recipe.imageThumbData! as Data)
        recipeInstrusctionsTextView.text = recipe.instructions
        showIngredientsorInstructions(selectedSegmentIndex: selectedSegment.selectedSegmentIndex)
    }
    
    func showIngredientsorInstructions(selectedSegmentIndex:Int) {
        if selectedSegmentIndex == 0{
            IngredientsView.isHidden = false
            recipeInstrusctionsTextView.isHidden = true
        }else if selectedSegmentIndex == 1 {
            recipeInstrusctionsTextView.isHidden = false
            IngredientsView.isHidden = true
        }
    }
    
    // -------------------------------------------------------------------------
    //MARK:-Actions
    @IBAction func webButtonPressed(_ sender: UIButton) {
        let sourceUrl = recipe?.source
        if sourceUrl != ""{
            openExternalUrl(url: sourceUrl!)
        }else {
            let message: MessageView = MessageView.viewFromNib(layout: .cardView)
            message.configureTheme(.error)
            message.configureContent(body: "Recipe web link seems to be invalid".localized)
            var config = SwiftMessages.defaultConfig
            config.presentationContext = .view(view)
            config.duration = .automatic
            config.presentationStyle = .top
            SwiftMessages.show(config: config, view: message)          }
    }
    @IBAction func youtubeButton(_ sender: UIButton) {
        let sourceUrl = recipe?.youtubeLink
        if sourceUrl != ""{
            openExternalUrl(url: sourceUrl!)
        }else {
            let message: MessageView = MessageView.viewFromNib(layout: .cardView)
            message.configureTheme(.error)
            message.configureContent(body: "Recipe youtube links is invalid".localized)
            var config = SwiftMessages.defaultConfig
            config.presentationContext = .view(view)
            config.duration = .automatic
            config.presentationStyle = .top
            SwiftMessages.show(config: config, view: message)        }
    }
    
    @IBAction func SavedButtonPressed(_ sender: UIButton) {
        let message: MessageView = MessageView.viewFromNib(layout: .cardView)
        message.configureTheme(.success)
        message.configureContent(body: "Recipe is already in Saved".localized)
        var config = SwiftMessages.defaultConfig
        config.presentationContext = .view(view)
        config.duration = .automatic
        config.presentationStyle = .top
    }
    
    @IBAction func segementIndexChanged(_ sender: UISegmentedControl) {
        showIngredientsorInstructions(selectedSegmentIndex: selectedSegment.selectedSegmentIndex)
    }


}
// -------------------------------------------------------------------------
// MARK: - Table view data source
extension SavedRecipeDetailsVC : UITableViewDataSource, UITableViewDelegate{
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return fetchedResultsController.sections?.count ?? 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return fetchedResultsController.sections?[section].numberOfObjects ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let aRecipe = fetchedResultsController.object(at: indexPath)
        let cell = tableView.dequeueReusableCell(withIdentifier: "IngredientsCell")!
        // Set the name and image
        cell.textLabel?.text = aRecipe.name
        cell.detailTextLabel?.text = aRecipe.quantity
        return cell
    }
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
}


// -------------------------------------------------------------------------
// MARK: -FetchedResults Controller
extension SavedRecipeDetailsVC : NSFetchedResultsControllerDelegate {
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        switch type {
        case .insert:
            tableView.insertRows(at: [newIndexPath!], with: .fade)
            break
        case .delete:
            tableView.deleteRows(at: [indexPath!], with: .fade)
            break
        case .update:
            tableView.reloadRows(at: [indexPath!], with: .fade)
        case .move:
            tableView.moveRow(at: indexPath!, to: newIndexPath!)
        default: () // Unsupported
        }
    }
    
    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        tableView.beginUpdates()
    }
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        tableView.endUpdates()
    }
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange sectionInfo: NSFetchedResultsSectionInfo, atSectionIndex sectionIndex: Int, for type: NSFetchedResultsChangeType) {
        let indexSet = IndexSet(integer: sectionIndex)
        switch type {
        case .insert: tableView.insertSections(indexSet, with: .fade)
        case .delete: tableView.deleteSections(indexSet, with: .fade)
        case .update, .move:
            fatalError("Invalid change type in controller(_:didChange:atSectionIndex:for:). Only .insert or .delete should be possible.")
        default: () // Unsupported
        }
    }
}
