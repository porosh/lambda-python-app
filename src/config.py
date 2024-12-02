import os

CONFIG = {
    "example_key": os.getenv("EXAMPLE_KEY", "default_value"),
    "other_key": os.getenv("OTHER_KEY", "other_default"),
}