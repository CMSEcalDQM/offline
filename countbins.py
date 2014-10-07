import ROOT
import sys

def countbins(dir):
    keys = dir.GetListOfKeys()
    plots = 0
    hBins = 0
    pBins = 0
    for key in [keys.At(i) for i in range(keys.GetEntries())]:
        obj = key.ReadObj()
        if not obj: continue
        
        if obj.InheritsFrom(ROOT.TDirectory.Class()):
            bins = countbins(obj)
            plots += bins[0]
            hBins += bins[1]
            pBins += bins[2]
        elif obj.IsA() == ROOT.TProfile.Class():
            plots += 1
            pBins += obj.GetNbinsX() + 2
        elif obj.IsA() == ROOT.TProfile2D.Class():
            plots += 1
            pBins += (obj.GetNbinsX() + 2) * (obj.GetNbinsY() + 2)
        elif obj.InheritsFrom(ROOT.TH1.Class()):
            plots += 1
            bins = obj.GetNbinsX() + 2
            if obj.GetDimension() >= 2:
                bins *= obj.GetNbinsY() + 2
            if obj.GetDimension() >= 3:
                bins *= obj.GetNbinsZ() + 2
            hBins += bins

    return (plots, hBins, pBins)

source = ROOT.TFile(sys.argv[1])

bins = countbins(source)

print bins
