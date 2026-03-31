require 'xcodeproj'

project_path = 'ChildCare AI.xcodeproj'
project = Xcodeproj::Project.open(project_path)

file_path = 'ChildCare AI/Features/Children/EditChildProfileView.swift'
target = project.targets.first

# Add file to project group
group = project.main_group.find_subpath('ChildCare AI/Features/Children', true)
file_ref = group.new_reference('EditChildProfileView.swift')

# Add file to target source build phase
target.source_build_phase.add_file_reference(file_ref)

project.save
