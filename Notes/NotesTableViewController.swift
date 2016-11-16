//
//  NotesTableViewController.swift
//  Notes
//
//  Created by Yohannes Wijaya on 8/4/16.
//  Copyright © 2016 Yohannes Wijaya. All rights reserved.
//


import UIKit

class NotesTableViewController: UITableViewController {
  
  // MARK: - Stored Properties
  
  var notes = [Notes]()
  
  // MARK: - IBAction Methods
  
  @IBAction func unwindToNotesTableViewController(sender: UIStoryboardSegue) {
    guard let validNotesViewController = sender.source as? NotesViewController, let validNote = validNotesViewController.note else { return }
    if self.presentedViewController is UINavigationController {
      let newIndexPath = IndexPath(row: self.notes.count, section: 0)
      self.notes.append(validNote)
      self.tableView.insertRows(at: [newIndexPath], with: .bottom)
    }
    else {
      guard let selectedIndexPath = self.tableView.indexPathForSelectedRow else { return }
      self.notes[selectedIndexPath.row] = validNote
      self.tableView.reloadRows(at: [selectedIndexPath], with: UITableViewRowAnimation.none)
    }
    self.saveNotes()
  }
  
  // MARK: - Helper Methods
  
  func loadSampleNotes() {
    guard let firstNote = Notes(entry: "Hello Sunshine! Come & tap me first!\n👇👇👇\n\nYou can power up your note by writing your **words** _like_ `these`, create an [url link](http://apple.com), or even make a todo list:\n\n* Watch WWDC videos.\n* Write code.\n* Fetch my girlfriend for a ride.\n* Write code.\n\nTap *Go!* to preview your enhanced note.\n\nTap *How?* to learn more.", dateOfCreation: CurrentDateAndTimeHelper.get()) else { return }
    guard let secondNote = Notes(entry: "Swipe me left or tap edit to delete.", dateOfCreation: CurrentDateAndTimeHelper.get()) else { return }
    guard let thirdNote = Notes(entry: "Tap edit to move me or delete me.", dateOfCreation: CurrentDateAndTimeHelper.get()) else { return }
    self.notes += [firstNote, secondNote, thirdNote]
  }
  
  // MARK: - NSCoding Methods
  
  func saveNotes() {
    let isSuccessfulSave = NSKeyedArchiver.archiveRootObject(self.notes, toFile: Notes.archiveURL.path)
    if !isSuccessfulSave { print("unable to save note...") }
  }
  
  func loadNotes() -> [Notes]? {
    return NSKeyedUnarchiver.unarchiveObject(withFile: Notes.archiveURL.path) as? [Notes]
  }
  
  // MARK: - UIViewController Methods
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    if let loadedNotes = self.loadNotes() {
      self.notes = loadedNotes
    }
    else {
      self.loadSampleNotes()
    }
    
    self.navigationController?.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName: UIColor(hexString: "#72889E")!]
    
    self.navigationItem.leftBarButtonItem = self.editButtonItem
    
    self.tableView.separatorStyle = .none
  }
  
  override func viewWillAppear(_ animated: Bool) {
    self.navigationItem.title = "\(self.notes.count) Notes"
  }
  
  override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    guard let validSegueIdentifier = segue.identifier, let validSegueIdentifierCase = NotesTableViewControllerSegue(rawValue: validSegueIdentifier) else {
        assertionFailure("Could not map segue identifier: \(segue.identifier)")
        return
    }
    
    switch validSegueIdentifierCase {
    case .segueToNotesViewControllerFromCell:
        guard let validNotesViewController = segue.destination as? NotesViewController,
            let selectedNoteCell = sender as? NotesTableViewCell,
            let selectedIndexPath = self.tableView.indexPath(for: selectedNoteCell) else { return }
        let selectedNote = self.notes[selectedIndexPath.row]
        validNotesViewController.note = selectedNote
    case .segueToNotesViewControllerFromAddButton:
        print("adding new note")
    }
  }
  
  // MARK: - UITableViewDataSource Methods
  
  override func numberOfSections(in tableView: UITableView) -> Int {
    return 1
  }
  
  override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return self.notes.count
  }
  
  override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCell(withIdentifier: "NotesTableViewCell", for: indexPath) as! NotesTableViewCell
    
    let note = self.notes[indexPath.row]
    
    cell.noteLabel.text = note.entry
    cell.noteModificationTimeStampLabel.text = note.dateModificationTimeStamp
    
    return cell
  }
  
  override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
    return true
  }
  
  override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
    if editingStyle == .delete {
      // Delete the row from the data source
      self.notes.remove(at: indexPath.row)
      self.saveNotes()
      tableView.deleteRows(at: [indexPath], with: .fade)
      self.navigationItem.title = "\(self.notes.count) Notes"
    }
  }
  
  override func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
    let noteTobeMoved = self.notes[sourceIndexPath.row]
    self.notes.remove(at: sourceIndexPath.row)
    self.notes.insert(noteTobeMoved, at: destinationIndexPath.row)
  }
}

// MARK: - NotesTableViewController Extension

extension NotesTableViewController {
    enum NotesTableViewControllerSegue: String {
        case segueToNotesViewControllerFromCell
        case segueToNotesViewControllerFromAddButton
    }
}
