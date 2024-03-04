//
//  SaintCell.swift
//  SaintsOfTheDay
//
//  Created by Максим Бобков on 29.02.2024.
//

import UIKit

final class SaintCell: UITableViewCell {
    
    // Вводим для реализации клика по ячейке для того, чтобы перейти на экран святого.
    var tap: ((Int?) -> Void)?
    
    // Икона святого
    private var saintIcon: UIImageView = {
        let view = UIImageView()
        view.backgroundColor = .lightGray
        view.contentMode = .scaleAspectFill
        view.clipsToBounds = true // Обрезание по границам
        return view
    }()
    
    // Текст вместо иконы
    private var saintIconLabel: UILabel = {
        let label = UILabel()
        label.text = "Нет\nиконы"
        label.textAlignment = .center
        label.backgroundColor = .lightGray
        label.numberOfLines = 0
        label.font = UIFont.systemFont(ofSize: 8)
        return label
    }()
    
    // Имя святого
    private var saintName: UILabel = {
        let label = UILabel()
        label.text = "Name"
        label.numberOfLines = 0
        label.textAlignment = .left
        return label
    }()
    
    private var saintId: Int
    
    
    // Функции viewDidLoad у ячейки нет, поэтому пользуемся инициализатором
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        
        self.saintId = 0
        
        super.init(style: style, reuseIdentifier: reuseIdentifier)

        backgroundColor = .clear // Чтобы ячейка была прозрачной (цвета фона)

        // Реализуем тап по ячейке списка для перехода на экран святого.
        let recognizer = UITapGestureRecognizer(target: self, action: #selector(cellClick))
        addGestureRecognizer(recognizer)

        // Выведено в extension
        setupUI()
        addConstraints()
    }
    
    // Обязательный инициализатор
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // После получения данных с сервера обновляем текст в лейбле и картинку
    func updateCell(saint: Saint) {

        // Используем highestPriorityIconUrlS для получения URL иконы с наивысшим приоритетом
        if let highestPriorityIconUrl = saint.highestPriorityIconUrlS(), let url = URL(string: highestPriorityIconUrl) {
            
            let task = URLSession.shared.dataTask(with: url) { data, response, error in
                
                // Если иконы не загружена, размещаем указание "нет иконы"
                if error != nil {
                    DispatchQueue.main.async {
                        self.saintIcon.image = nil
                        self.saintIconLabel.isHidden = false
                    }
                    return
                }
                
                // Иначе отображаем икону
                if let data = data {
                    DispatchQueue.main.async {
                        self.saintIcon.image = UIImage(data: data)
                        self.saintIconLabel.isHidden = true
                    }
                }
            }

            task.resume()
            
        } else {
            // Если URL изображения недоступен, размещаем указание "нет иконы"
            DispatchQueue.main.async {
                self.saintIcon.image = nil
                self.saintIconLabel.isHidden = false
            }
        }
        
        saintName.text = saint.name
        saintId = saint.id
    }
}



private extension SaintCell {
    
    private func setupUI() {
        
        // В случае с ячейками элементы добавляем не на view, а на contentView, чтобы в дальнейшем наша ячейка могла подстраиваться под размеры отведённой для неё области
        contentView.addSubview(saintIcon)
        contentView.addSubview(saintIconLabel)
        contentView.addSubview(saintName)
    }
    
    private func addConstraints() {
        
        saintIcon.translatesAutoresizingMaskIntoConstraints = false
        saintIconLabel.translatesAutoresizingMaskIntoConstraints = false
        saintName.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            
            saintIcon.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            saintIcon.leftAnchor.constraint(equalTo: contentView.leftAnchor, constant: 15),
            saintIcon.heightAnchor.constraint(equalToConstant: 40),
            saintIcon.widthAnchor.constraint(equalTo: saintIcon.heightAnchor),
            saintIcon.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 5),
            saintIcon.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -5),

            saintIconLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            saintIconLabel.leftAnchor.constraint(equalTo: contentView.leftAnchor, constant: 15),
            saintIconLabel.heightAnchor.constraint(equalTo: saintIcon.widthAnchor),
            saintIconLabel.widthAnchor.constraint(equalTo: saintIcon.heightAnchor),
            saintIconLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 5),
            saintIconLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -5),
            
            saintName.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            saintName.leftAnchor.constraint(equalTo: saintIcon.rightAnchor, constant: 20),
            saintName.rightAnchor.constraint(equalTo: contentView.rightAnchor, constant: -10),
        ])
    }
}



// MARK: objc methods

// Создаём расширение для выноса всех objc-методов, чтобы лучше ориентироваться по коду
private extension SaintCell {
    
    // Реализуем тап по ячейке списка для перехода на экран святого.
    @objc private func cellClick() {
        
        // Передаём ID святого в SaintViewController
        tap?(saintId)
    }
}
