import logging
import sys

from pledge_processing import Pledge


def main():
    logging.warning("Main")

    pledge = Pledge()
    pledge.check_model_files()
    pledge.pledge_processing()


if __name__ == "__main__":
    main()
    sys.exit(0)
