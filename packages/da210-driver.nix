{ pkgs, ... }:

pkgs.stdenv.mkDerivation rec {
  pname = "tsc-da210-barcode-driver";
  version = "1.2.13";

  # We expect driver files to live under the repository root. The bundle may be
  # placed in one of a few locations depending on how it was added to the
  # repo. Use the repo root as `src` and look for the actual bundle path(s)
  # during installPhase so we can accept either layout:
  #  - drivers/printers/DA-210/barcodedriver-1.2.13
  #  - files/da210/
  #  - files/rastertocls (single-file legacy)
  # repo root (parent directory of `packages/`)
  src = ../.;

  buildInputs = [];

  installPhase = ''

    mkdir -p "$out/lib/cups/filter" "$out/lib/cups/backend" \
      "$out/share/ppd/tscbarcode" "$out/share/cups/model/tscbarcode" "$out/share/tscbarcode" \
      "$out/share/applications"

    # Candidate bundle locations relative to the repo root
    driver_bundle1="$src/drivers/printers/DA-210/barcodedriver-1.2.13"
    driver_bundle2="$src/files/da210"
    driver_bundle3="$src/da210"
    bundle=""

    if [ -d "$driver_bundle1" ]; then
      bundle="$driver_bundle1"
    elif [ -d "$driver_bundle2" ]; then
      bundle="$driver_bundle2"
    elif [ -d "$driver_bundle3" ]; then
      bundle="$driver_bundle3"
    else
      # fallback: maybe the repo placed single files at repo root
      bundle="$src"
    fi

    # prefer vendor `rastertobarcodetspl` if present in the bundle
    if [ -f "$bundle/rastertobarcodetspl" ]; then
      install -m 0755 "$bundle/rastertobarcodetspl" "$out/lib/cups/filter/rastertobarcodetspl"
    fi

    # vendor may provide rastertocls (legacy) either at bundle or repo root
    if [ -f "$bundle/rastertocls" ]; then
      install -m 0755 "$bundle/rastertocls" "$out/lib/cups/filter/rastertocls"
    elif [ -f "$src/rastertocls" ]; then
      install -m 0755 "$src/rastertocls" "$out/lib/cups/filter/rastertocls"
    fi

    # copy backend programs
    if [ -d "$bundle/backend" ]; then
      cp -a "$bundle/backend/"* "$out/lib/cups/backend/" 2>/dev/null || true
      chmod -R 0755 "$out/lib/cups/backend" || true
    fi

    # copy PPDs into both common locations used by CUPS
    if [ -d "$bundle/ppd" ]; then
      cp -a "$bundle/ppd/"* "$out/share/ppd/tscbarcode/" 2>/dev/null || true
      cp -a "$bundle/ppd/"* "$out/share/cups/model/tscbarcode/" 2>/dev/null || true
      chmod -R 0644 "$out/share/ppd/tscbarcode"/* 2>/dev/null || true
      chmod -R 0644 "$out/share/cups/model/tscbarcode"/* 2>/dev/null || true
    fi

    # copy UI/aux files (thermalprinterui, thermalprinterui.png, thermalprinterut)
    if [ -f "$bundle/thermalprinterui" ]; then
      install -D -m 0755 "$bundle/thermalprinterui" "$out/share/tscbarcode/thermalprinterui"
    fi
    if [ -f "$bundle/thermalprinterui.png" ]; then
      install -D -m 0644 "$bundle/thermalprinterui.png" "$out/share/tscbarcode/thermalprinterui.png"
    fi
    if [ -f "$bundle/thermalprinterut" ]; then
  install -D -m 0755 "$bundle/thermalprinterut" "$out/share/tscbarcode/thermalprinterut"
  # preserve vendor intent: we install non-setuid here; if you need the
  # binary to be setuid root on the target machine, set the mode during
  # NixOS activation (e.g. via a module that creates a tmpfiles rule).
    fi

    # install uninstall/install scripts and desktop file if present
    if [ -f "$bundle/install-driver" ]; then
      install -D -m 0755 "$bundle/install-driver" "$out/share/tscbarcode/install-driver"
    fi
    if [ -f "$bundle/uninstall-driver" ]; then
      install -D -m 0755 "$bundle/uninstall-driver" "$out/share/tscbarcode/uninstall-driver"
    fi
    if [ -f "$bundle/barcodeprintersetting.desktop" ]; then
      install -D -m 0644 "$bundle/barcodeprintersetting.desktop" "$out/share/applications/barcodeprintersetting.desktop"
    fi

    # copy a few test/support files the vendor installer ships
    if [ -f "$bundle/tsc_test_11.prn" ]; then
      install -D -m 0644 "$bundle/tsc_test_11.prn" "$out/share/tscbarcode/tsc_test_11.prn"
    fi
    if [ -f "$bundle/teststatus" ]; then
      install -D -m 0644 "$bundle/teststatus" "$out/share/tscbarcode/teststatus"
    fi
    if [ -f "$bundle/crontest" ]; then
      install -D -m 0644 "$bundle/crontest" "$out/share/tscbarcode/crontest"
    fi

    # make everything readable
    chmod -R a+rX "$out"
  '';

  meta = with pkgs.lib; {
    description = "TSC / Citizen DA-210 barcode printer driver (CUPS filter/backend/PPD)";
    license = licenses.unfree;
    platforms = platforms.linux;
  };
}
