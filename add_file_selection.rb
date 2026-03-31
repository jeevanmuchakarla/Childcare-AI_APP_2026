require 'xcodeproj'

project_path = "ChildCare AI.xcodeproj"
project = Xcodeproj::Project.open(project_path)
target = project.targets.first

group = project.main_group.find_subpath(File.join("ChildCare AI", "Features", "Children"), true)
file_ref = group.new_reference("ChildSelectionView.swift")
target.add_file_references([file_ref])

project.save
