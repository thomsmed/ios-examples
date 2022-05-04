//
//  FullPageViewController.swift
//  BottomSheetController
//
//  Created by Thomas Asheim Smedmann on 04/05/2022.
//

import UIKit

class FullPageViewController: BottomSheetController {

    override func loadView() {
        view = UIView()

        let textView = UITextView()
        textView.textColor = .black
        textView.backgroundColor = .clear
        textView.text = """
        Lorem ipsum dolor sit amet, consectetur adipiscing elit. Suspendisse mattis, est sed facilisis auctor, velit nunc facilisis lorem, quis consectetur elit lorem eget nisl. Vivamus porttitor porttitor congue. Maecenas venenatis nunc eu sodales egestas. Phasellus ut ante in augue mollis aliquet. Morbi varius finibus orci, quis varius quam consectetur ut. Donec placerat quam at dictum fringilla. Aenean a lacus eget lacus elementum aliquam. Nullam ultrices nulla augue, sed mattis orci elementum eleifend. Proin viverra accumsan est vel aliquam.

        Proin ac elementum velit. Duis non imperdiet dui. Nunc et nisi in magna dignissim tristique sit amet sed nibh. Praesent eu enim vitae diam lobortis ornare et vel nisl. Ut ut lorem at ante viverra euismod eget eu orci. Nullam vel neque odio. Cras ac ornare mi, eu tempor mi. Ut tellus ipsum, accumsan vel arcu eget, tincidunt malesuada justo. Cras aliquet mattis metus, mollis euismod est gravida quis.

        Proin mattis orci quam, nec maximus leo tincidunt eu. Aenean id tellus sit amet urna cursus lacinia pretium quis ipsum. Ut non vehicula neque. Etiam pulvinar justo at dui sagittis condimentum. Phasellus aliquet nisi magna, eu malesuada velit tempus id. Nam non nisl tellus. Curabitur in metus fringilla libero consequat interdum. Mauris sagittis euismod nisi a viverra. Curabitur vitae dui nunc. Curabitur malesuada laoreet pharetra. Suspendisse a finibus tortor, non placerat metus. Etiam est tellus, sodales condimentum condimentum eu, dignissim nec quam. Mauris vitae eros nunc. Mauris non pretium libero. Donec malesuada fringilla augue, nec lacinia nisi ullamcorper sed. Suspendisse lacinia feugiat orci, eget molestie elit vestibulum ac.

        Suspendisse potenti. In hac habitasse platea dictumst. Fusce ex sapien, congue sit amet ullamcorper nec, mollis nec nisi. Fusce vitae luctus nunc. Vivamus iaculis, arcu et ultrices rutrum, velit odio viverra lacus, non vehicula massa justo sed ante. In risus risus, posuere eget condimentum quis, convallis quis tellus. Fusce mattis ullamcorper neque vitae vulputate. Duis mauris tortor, accumsan ut massa ac, consectetur lacinia felis. Donec id rhoncus lacus. Aenean lorem nisl, luctus at mattis sed, feugiat nec neque. In tempus quam sed massa ultricies, vel convallis libero tincidunt.

        Nunc tempor finibus lacus, eu ultrices massa imperdiet vitae. Nulla tincidunt eu mauris in dictum. Ut aliquet pharetra molestie. Cras nec sollicitudin tellus, et accumsan lorem. Nam elementum nisl tellus, quis pharetra ipsum cursus nec. Cras nec vulputate mauris. Phasellus consequat posuere nunc non hendrerit. Lorem ipsum dolor sit amet, consectetur adipiscing elit.

        Lorem ipsum dolor sit amet, consectetur adipiscing elit. Suspendisse mattis, est sed facilisis auctor, velit nunc facilisis lorem, quis consectetur elit lorem eget nisl. Vivamus porttitor porttitor congue. Maecenas venenatis nunc eu sodales egestas. Phasellus ut ante in augue mollis aliquet. Morbi varius finibus orci, quis varius quam consectetur ut. Donec placerat quam at dictum fringilla. Aenean a lacus eget lacus elementum aliquam. Nullam ultrices nulla augue, sed mattis orci elementum eleifend. Proin viverra accumsan est vel aliquam.

        Proin ac elementum velit. Duis non imperdiet dui. Nunc et nisi in magna dignissim tristique sit amet sed nibh. Praesent eu enim vitae diam lobortis ornare et vel nisl. Ut ut lorem at ante viverra euismod eget eu orci. Nullam vel neque odio. Cras ac ornare mi, eu tempor mi. Ut tellus ipsum, accumsan vel arcu eget, tincidunt malesuada justo. Cras aliquet mattis metus, mollis euismod est gravida quis.

        Proin mattis orci quam, nec maximus leo tincidunt eu. Aenean id tellus sit amet urna cursus lacinia pretium quis ipsum. Ut non vehicula neque. Etiam pulvinar justo at dui sagittis condimentum. Phasellus aliquet nisi magna, eu malesuada velit tempus id. Nam non nisl tellus. Curabitur in metus fringilla libero consequat interdum. Mauris sagittis euismod nisi a viverra. Curabitur vitae dui nunc. Curabitur malesuada laoreet pharetra. Suspendisse a finibus tortor, non placerat metus. Etiam est tellus, sodales condimentum condimentum eu, dignissim nec quam. Mauris vitae eros nunc. Mauris non pretium libero. Donec malesuada fringilla augue, nec lacinia nisi ullamcorper sed. Suspendisse lacinia feugiat orci, eget molestie elit vestibulum ac.

        Suspendisse potenti. In hac habitasse platea dictumst. Fusce ex sapien, congue sit amet ullamcorper nec, mollis nec nisi. Fusce vitae luctus nunc. Vivamus iaculis, arcu et ultrices rutrum, velit odio viverra lacus, non vehicula massa justo sed ante. In risus risus, posuere eget condimentum quis, convallis quis tellus. Fusce mattis ullamcorper neque vitae vulputate. Duis mauris tortor, accumsan ut massa ac, consectetur lacinia felis. Donec id rhoncus lacus. Aenean lorem nisl, luctus at mattis sed, feugiat nec neque. In tempus quam sed massa ultricies, vel convallis libero tincidunt.

        Nunc tempor finibus lacus, eu ultrices massa imperdiet vitae. Nulla tincidunt eu mauris in dictum. Ut aliquet pharetra molestie. Cras nec sollicitudin tellus, et accumsan lorem. Nam elementum nisl tellus, quis pharetra ipsum cursus nec. Cras nec vulputate mauris. Phasellus consequat posuere nunc non hendrerit. Lorem ipsum dolor sit amet, consectetur adipiscing elit.
        """

        textView.translatesAutoresizingMaskIntoConstraints = false

        view.addSubview(textView)

        NSLayoutConstraint.activate([
            textView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 32),
            textView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            textView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
            textView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
        ])

        view.backgroundColor = .white
    }
}
