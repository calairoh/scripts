#!/bin/bash

# A script to simplify Kubernetes port-forwarding.
# It automatically finds a pod by a partial name and forwards a specified port.

# Check if the correct number of arguments are provided.
if [ "$#" -ne 3 ]; then
  echo "Usage: $0 <partial-pod-name> <local-port>:<pod-port> <namespace>"
  echo "Example: $0 crud-service 3001:3000 p4samd-governance-jam"
  exit 1
fi

# Assign command-line arguments to variables for clarity.
PARTIAL_POD_NAME=$1
PORT_MAPPING=$2
NAMESPACE=$3

echo "Searching for pods matching '$PARTIAL_POD_NAME' in namespace '$NAMESPACE'..."

# Find all pods matching the partial name and store them in an array.
# Using a while loop with 'read' for better compatibility across different shells.
MATCHING_PODS=()
while IFS= read -r pod_name; do
  MATCHING_PODS+=("$pod_name")
done < <(kubectl get pods -n "$NAMESPACE" | grep "$PARTIAL_POD_NAME" | awk '{print $1}')

# Check if any pods were found.
if [ ${#MATCHING_PODS[@]} -eq 0 ]; then
  echo "Error: No pods found matching '$PARTIAL_POD_NAME' in namespace '$NAMESPACE'."
  exit 1
fi

# If only one pod is found, proceed with it directly.
if [ ${#MATCHING_PODS[@]} -eq 1 ]; then
  POD_NAME=${MATCHING_PODS[0]}
  echo "Found one pod: $POD_NAME"
else
  # If multiple pods are found, list them and prompt the user to choose.
  echo "Found multiple pods. Please select one by entering its number:"
  # Loop through the array and display each pod with a number.
  for i in "${!MATCHING_PODS[@]}"; do
    echo "$((i+1))) ${MATCHING_PODS[i]}"
  done

  # Read user input for the pod selection.
  read -p "Enter number: " SELECTION

  # Validate the user's input.
  if [[ "$SELECTION" =~ ^[0-9]+$ ]] && [ "$SELECTION" -ge 1 ] && [ "$SELECTION" -le "${#MATCHING_PODS[@]}" ]; then
    # Adjust for 0-based array index and select the pod.
    POD_NAME=${MATCHING_PODS[$((SELECTION-1))]}
    echo "You selected: $POD_NAME"
  else
    echo "Invalid selection. Please run the script again with a valid number."
    exit 1
  fi
fi

echo "Starting port-forwarding for pod: $POD_NAME..."

# Execute the port-forward command.
kubectl port-forward "$POD_NAME" "$PORT_MAPPING" -n "$NAMESPACE"

