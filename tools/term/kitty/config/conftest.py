import sys
from unittest.mock import MagicMock

# Stub kitty runtime modules unavailable outside of kitty
sys.modules["kitty"] = MagicMock()
sys.modules["kitty.boss"] = MagicMock()
sys.modules["kitty.fast_data_types"] = MagicMock()
sys.modules["kitty.tab_bar"] = MagicMock()
sys.modules["kitty.utils"] = MagicMock()
