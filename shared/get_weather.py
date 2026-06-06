#!/usr/bin/env python3
import re, argparse
from datetime import datetime
from urllib.request import urlopen


def get_ip_city():
    try:
        with urlopen("https://ipinfo.io/city", timeout=3) as resp:
            return resp.read().decode().strip().replace(" ", "+")
    except Exception:
        return None


def fetch_weather(location, unit):
    unit_param = "&u" if unit == "F" else "&m"
    url = f'https://wttr.in/{location.replace(" ", "+").replace(",", "")}?format=%T:::%l:::%C,+%t{unit_param}'
    try:
        with urlopen(url, timeout=5) as resp:
            raw = resp.read().decode().strip()
        parts = raw.split(":::")
        if len(parts) != 3:
            return None
        raw_time, loc_name, condition = parts
        time_part = re.match(r"(\d{2}:\d{2})", raw_time)
        if time_part:
            local_time = datetime.strptime(time_part.group(1), "%H:%M").strftime(
                "%I:%M %p"
            )
        else:
            local_time = raw_time
        condition = re.sub(r"\s+,", ",", condition).strip()
        condition = condition.replace("°", "")
        return f"{loc_name.strip()}:::{ local_time}:::{condition}"
    except Exception:
        return None


parser = argparse.ArgumentParser()
parser.add_argument("location", nargs="*")
parser.add_argument("-u", "--unit", choices=["F", "C"], default="F")
args = parser.parse_args()

location = " ".join(args.location).strip() if args.location else get_ip_city()
if location:
    result = fetch_weather(location, args.unit)
    if result:
        print(result)
