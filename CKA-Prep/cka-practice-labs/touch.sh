# Confirm if you want to proceed with creating lab.md
echo "Do you want to proceed with creating lab.md for Day 1 in 01-cluster-architecture?"
read -r confirmation

if [ "$confirmation" == "yes" ]; then
    # Create lab.md and add content
    echo "# CKA Lab: Day 1 -- Cluster Architecture" > 01-cluster-architecture/lab.md
    echo "" >> 01-cluster-architecture/lab.md
    echo "## Tasks for Day 1" >> 01-cluster-architecture/lab.md
    echo "- [ ] Install `kind`" >> 01-cluster-architecture/lab.md
    echo "- [ ] Create a cluster with `kind"` >> 01-cluster-architecture/lab.md
    echo "- [ ] Explore the cluster components using `kubectl`" >> 01-cluster-architecture/lab.md

    # Add a commit message
    git add .
    git commit -m "Initial setup: Created lab.md for Day 1 in 01-cluster-architecture"

    echo "lab.md created successfully."
else
    echo "Operation cancelled. No changes made."
fi
