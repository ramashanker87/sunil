import os

participant_name = os.environ.get("PARTICIPANT_NAME", "sunil")
print(f"Hello {participant_name} from EKS Application")
