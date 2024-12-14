import logging
from logging.handlers import RotatingFileHandler


def create_logger(name, log_file, level=logging.INFO, max_bytes=100 * 1024 * 1024, backup_count=5):
    f_handler = RotatingFileHandler(log_file, maxBytes=max_bytes, backupCount=backup_count)
    f_handler.setLevel(level)
    # Create formatters and add it to handlers
    f_format = logging.Formatter('%(asctime)s - %(name)s - %(levelname)s - %(message)s')
    f_handler.setFormatter(f_format)
    # Configure logging
    logger = logging.getLogger(name)
    logger.setLevel(level)
    # Creates a rotating file handler, rotates after 100MB and keeps 5 logs

    # Add handlers to the logger
    logger.addHandler(f_handler)
    return logger
