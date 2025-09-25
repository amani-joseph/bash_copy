# bash_copy
# 📂 Copy Files Script

A Bash utility that **recursively copies files** from a source directory (and its subdirectories) into a single flat target directory.  
It avoids filename conflicts, supports renaming with patterns, and automatically organizes video files (`.mp4`) into a dedicated `videos/` folder.  

---

## ✨ Features

- ✅ **Recursive copy**: Collects all files from nested directories.  
- ✅ **Conflict-safe**: If duplicate filenames exist, the script generates unique names using path-based hashes.  
- ✅ **Custom renaming**: Use the `-r` flag with a pattern to rename files in sequence (e.g., `file_001.txt`, `file_002.txt`).  
- ✅ **Video isolation**: `.mp4` files are automatically placed into a `videos/` subdirectory inside the target.  
- ✅ **Cross-platform**: Works on macOS and Linux.  

---

## 🔧 Installation

1. Save the script as `copy_files.sh`.  
2. Make it executable:

   ```bash
   chmod +x copy_files.sh
