from pathlib import Path
from PIL import Image, ImageChops

pairs = {
    "frm_va_Auftragstamm": (
        "artifacts/html-screenshots/frm_va_Auftragstamm.png",
        "Screenshots ACCESS Formulare/frm_VA_Auftragstamm.jpg",
    ),
    "frm_MA_Mitarbeiterstamm": (
        "artifacts/html-screenshots/frm_MA_Mitarbeiterstamm.png",
        "Screenshots ACCESS Formulare/frm_MA_Mitarbeiterstamm.jpg",
    ),
    "frm_KD_Kundenstamm": (
        "artifacts/html-screenshots/frm_KD_Kundenstamm.png",
        "Screenshots ACCESS Formulare/frm_KD_Kundenstamm.jpg",
    ),
    "frm_DP_Dienstplan_MA": (
        "artifacts/html-screenshots/frm_DP_Dienstplan_MA.png",
        "Screenshots ACCESS Formulare/frm_DP_Diensplan_MA.jpg",
    ),
    "frm_MA_VA_Schnellauswahl": (
        "artifacts/html-screenshots/frm_MA_VA_Schnellauswahl.png",
        "Screenshots ACCESS Formulare/frm_ma_va_schnellauswahl.jpg",
    ),
}

def compute_stats(diff_image: Image.Image):
    hist = diff_image.histogram()
    sq = sum(v * (i % 256) ** 2 for i, v in enumerate(hist))
    rms = (sq / (diff_image.width * diff_image.height)) ** 0.5
    total = sum(sum(pixel) for pixel in diff_image.getdata())
    avg = total / (diff_image.width * diff_image.height * 3)
    return rms, avg


def main():
    for name, (html_path, access_path) in pairs.items():
        html_file = Path(html_path)
        access_file = Path(access_path)
        if not html_file.exists() or not access_file.exists():
            print(f"{name}: missing file")
            continue

        html_img = Image.open(html_file).convert("RGB").resize((1024, 768))
        access_img = Image.open(access_file).convert("RGB").resize((1024, 768))
        diff = ImageChops.difference(html_img, access_img)
        rms, avg = compute_stats(diff)
        diff_dir = Path("artifacts/html-screenshots/diffs")
        diff_dir.mkdir(parents=True, exist_ok=True)
        diff_path = diff_dir / f"{name}-diff.png"
        diff.save(diff_path)
        print(f"{name}: rms={rms:.2f}, avg_pixel_diff={avg:.2f}")


if __name__ == "__main__":
    main()
