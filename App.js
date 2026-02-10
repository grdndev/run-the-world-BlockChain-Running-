import "./global.css";
import React, { useState, useEffect } from 'react';
import {
  StyleSheet,
  Text,
  View,
  ScrollView,
  TouchableOpacity,
  SafeAreaView,
  StatusBar,
  Dimensions,
  Image,
  Animated
} from 'react-native';
import {
  Users,
  Trophy,
  Map as MapIcon,
  LayoutDashboard,
  Coins,
  Gem,
  ShieldCheck,
  TrendingUp,
  MapPin,
  Lock,
  Flag,
  ChevronRight,
  Info
} from 'lucide-react-native';

const { width } = Dimensions.get('window');

// --- CONSTANTS & LOGIC ---
const GRADES = {
  STARTER: { name: 'Starter', minRpc: 0, minPts: 0, color: '#FFB800' },
  DEBUTANT: { name: 'Débutant', minRpc: 15000, minPts: 500, color: '#FF8A00' },
  CONFIRME: { name: 'Confirmé', minRpc: 30000, minPts: 800, color: '#FF5C00' },
  EXPERT: { name: 'Expert', minRpc: 200000, minPts: 20000, color: '#E60000' },
};

const RPC_CONVERSION_RATE = 10; // 1 pt = 10 RPC

// --- COMPONENTS ---

const GlassCard = ({ children, style }) => (
  <View style={[styles.glassCard, style]}>
    {children}
  </View>
);

const Badge = ({ label, color }) => (
  <View style={[styles.badge, { backgroundColor: color }]}>
    <Text style={styles.badgeText}>{label}</Text>
  </View>
);

export default function App() {
  // --- STATE ---
  const [player, setPlayer] = useState({
    username: 'Ratlamarche',
    grade: 'STARTER',
    rpc: 8000, // Starting bonus
    ozi: 0,
    pts: 854,
    km: 154.2,
    idValidityDays: 8,
    nationality: 'FRANCE',
    league: 3,
    rank: 246
  });

  const [activeTab, setActiveTab] = useState('dashboard');

  // Logic to determine grade based on wealth and performance
  const currentGradeObj = GRADES[player.grade];

  return (
    <SafeAreaView style={styles.container}>
      <StatusBar barStyle="light-content" />

      <ScrollView
        style={styles.scrollView}
        showsVerticalScrollIndicator={false}
        contentContainerStyle={{ paddingBottom: 100 }}
      >
        {/* Header */}
        <View style={styles.header}>
          <View>
            <Text style={styles.greeting}>Bonjour,</Text>
            <Text style={styles.username}>{player.username}</Text>
          </View>
          <TouchableOpacity style={styles.notifBtn}>
            <Users color="#64748b" size={24} />
          </TouchableOpacity>
        </View>

        {/* PLAYER CARD ID */}
        <GlassCard style={styles.playerCard}>
          <View style={styles.playerInfoRow}>
            <View style={styles.avatarContainer}>
              <Image
                source={{ uri: `https://api.dicebear.com/7.x/avataaars/svg?seed=${player.username}` }}
                style={styles.avatar}
              />
            </View>
            <View style={styles.playerMeta}>
              <View style={styles.rankRow}>
                <Badge label={currentGradeObj.name} color={currentGradeObj.color} />
                <View style={styles.nationRow}>
                  <Flag size={12} color="#3b82f6" />
                  <Text style={styles.nationText}>{player.nationality}</Text>
                </View>
              </View>
              <Text style={styles.walletTitle}>WALLET STATUS</Text>
            </View>
            <View style={styles.idStatus}>
              <View style={styles.statusBadge}>
                <ShieldCheck size={14} color="#FF8A00" />
                <Text style={styles.statusText}>ID OK</Text>
              </View>
              <Text style={styles.idExpiry}>Exp: {player.idValidityDays}j</Text>
            </View>
          </View>

          {/* Wallet Mini-Grid */}
          <View style={styles.walletGrid}>
            <View style={styles.walletItem}>
              <Text style={styles.currencyLabel}>RPC</Text>
              <View style={styles.currencyValueRow}>
                <Coins size={16} color="#fbbf24" />
                <Text style={styles.currencyValue}>{player.rpc.toLocaleString()}</Text>
              </View>
            </View>
            <View style={styles.walletItem}>
              <Text style={styles.currencyLabel}>OZI</Text>
              <View style={styles.currencyValueRow}>
                <Gem size={16} color="#60a5fa" />
                <Text style={styles.currencyValue}>{player.ozi.toFixed(2)}</Text>
              </View>
            </View>
          </View>

          {/* Performance Summary */}
          <View style={styles.perfRow}>
            <View>
              <Text style={styles.perfLabel}>SCORE</Text>
              <View style={styles.perfValueRow}>
                <Text style={styles.ptsValue}>{player.pts}</Text>
                <Text style={styles.ptsUnit}>PTS</Text>
              </View>
            </View>
            <View style={{ alignItems: 'flex-end' }}>
              <Text style={styles.perfLabel}>DISTANCE</Text>
              <View style={styles.perfValueRow}>
                <Text style={styles.kmValue}>{player.km}</Text>
                <Text style={styles.kmUnit}>KM</Text>
              </View>
            </View>
          </View>
        </GlassCard>

        {/* LEAGUE DASHBOARD */}
        <View style={styles.sectionHeader}>
          <Text style={styles.sectionTitle}>Ma League</Text>
          <Text style={styles.periodText}>Période P1</Text>
        </View>

        <GlassCard style={styles.leagueCard}>
          <View style={styles.leagueTop}>
            <Text style={styles.leagueRank}>LEAGUE {player.league}</Text>
            <Text style={styles.globalRank}>#{player.rank} GLOBAL</Text>
          </View>
          <View style={styles.progressBarBg}>
            <View style={[styles.progressBarFill, { width: '65%' }]} />
          </View>
          <View style={styles.maintanceRow}>
            <View style={styles.maintenanceIndicator}>
              <TrendingUp size={14} color="#4ade80" />
              <Text style={styles.maintenanceText}>Maintien Assuré (+{(player.pts - 10)} pts)</Text>
            </View>
            <TouchableOpacity>
              <Info size={16} color="#64748b" />
            </TouchableOpacity>
          </View>
        </GlassCard>

        {/* LAND CONQUEST PREVIEW */}
        <View style={styles.sectionHeader}>
          <Text style={styles.sectionTitle}>Conquête Territoriale</Text>
        </View>

        <View style={styles.mapPreview}>
          <View style={styles.mapGrid}>
            {[...Array(16)].map((_, i) => (
              <View key={i} style={[styles.mapCell, i === 5 && styles.activeCell]} />
            ))}
          </View>
          <View style={styles.mapOverlay}>
            <GlassCard style={styles.conquestCard}>
              <MapPin size={32} color="#FF8A00" style={{ marginBottom: 12 }} />
              <Text style={styles.landTitle}>LAND #2453 DISPONIBLE</Text>
              <Text style={styles.landDesc}>Zone Paris / Europe</Text>
              <TouchableOpacity style={styles.exploreBtn}>
                <Text style={styles.exploreBtnText}>EXPLORER LA ZONE</Text>
              </TouchableOpacity>
            </GlassCard>
          </View>
        </View>

        {/* GRADE PROGRESSION PREVIEW */}
        <GlassCard style={styles.lockCard}>
          <View style={styles.lockIconContainer}>
            <Lock size={20} color="#475569" />
          </View>
          <View style={styles.lockTextContainer}>
            <Text style={styles.lockTitle}>GRADE SUIVANT : DÉBUTANT</Text>
            <Text style={styles.lockSubtitle}>Requis: 15.000 RPC & 500 Pts</Text>
          </View>
          <ChevronRight size={20} color="#475569" />
        </GlassCard>

      </ScrollView>

      {/* BOTTOM TAB BAR */}
      <View style={styles.tabBar}>
        <TouchableOpacity style={styles.tabItem} onPress={() => setActiveTab('dashboard')}>
          <LayoutDashboard size={24} color={activeTab === 'dashboard' ? '#FF8A00' : '#64748b'} />
          <Text style={[styles.tabText, activeTab === 'dashboard' && styles.tabTextActive]}>HOME</Text>
        </TouchableOpacity>
        <TouchableOpacity style={styles.tabItem} onPress={() => setActiveTab('map')}>
          <MapIcon size={24} color={activeTab === 'map' ? '#FF8A00' : '#64748b'} />
          <Text style={[styles.tabText, activeTab === 'map' && styles.tabTextActive]}>MAP</Text>
        </TouchableOpacity>
        <TouchableOpacity style={styles.tabItem} onPress={() => setActiveTab('leaderboard')}>
          <Trophy size={24} color={activeTab === 'leaderboard' ? '#FF8A00' : '#64748b'} />
          <Text style={[styles.tabText, activeTab === 'leaderboard' && styles.tabTextActive]}>REWARDS</Text>
        </TouchableOpacity>
      </View>
    </SafeAreaView>
  );
}

const styles = StyleSheet.create({
  container: {
    flex: 1,
    backgroundColor: '#05080F',
  },
  scrollView: {
    paddingHorizontal: 20,
  },
  header: {
    flexDirection: 'row',
    justifyContent: 'space-between',
    alignItems: 'center',
    marginTop: 20,
    marginBottom: 24,
  },
  greeting: {
    color: '#94a3b8',
    fontSize: 14,
    fontFamily: 'System',
  },
  username: {
    color: '#ffffff',
    fontSize: 24,
    fontWeight: '900',
    fontFamily: 'System',
    textTransform: 'uppercase',
  },
  notifBtn: {
    width: 44,
    height: 44,
    borderRadius: 12,
    backgroundColor: '#1e293b',
    justifyContent: 'center',
    alignItems: 'center',
  },
  glassCard: {
    backgroundColor: 'rgba(255, 255, 255, 0.05)',
    borderRadius: 24,
    borderWidth: 1,
    borderColor: 'rgba(255, 255, 255, 0.1)',
    padding: 20,
  },
  playerCard: {
    marginBottom: 24,
    overflow: 'hidden',
  },
  playerInfoRow: {
    flexDirection: 'row',
    alignItems: 'center',
    marginBottom: 20,
  },
  avatarContainer: {
    width: 60,
    height: 60,
    borderRadius: 30,
    borderWidth: 2,
    borderColor: '#FF8A00',
    overflow: 'hidden',
  },
  avatar: {
    width: '100%',
    height: '100%',
  },
  playerMeta: {
    marginLeft: 15,
    flex: 1,
  },
  rankRow: {
    flexDirection: 'row',
    alignItems: 'center',
    marginBottom: 4,
  },
  badge: {
    paddingHorizontal: 10,
    paddingVertical: 3,
    borderRadius: 10,
    marginRight: 8,
  },
  badgeText: {
    color: '#000',
    fontSize: 10,
    fontWeight: '800',
    textTransform: 'uppercase',
  },
  nationRow: {
    flexDirection: 'row',
    alignItems: 'center',
  },
  nationText: {
    color: '#94a3b8',
    fontSize: 10,
    marginLeft: 4,
    fontWeight: '700',
  },
  walletTitle: {
    color: '#475569',
    fontSize: 9,
    fontWeight: '900',
    letterSpacing: 1,
  },
  idStatus: {
    alignItems: 'flex-end',
  },
  statusBadge: {
    flexDirection: 'row',
    alignItems: 'center',
    backgroundColor: 'rgba(255, 138, 0, 0.1)',
    paddingHorizontal: 8,
    paddingVertical: 4,
    borderRadius: 8,
    marginBottom: 4,
  },
  statusText: {
    color: '#FF8A00',
    fontSize: 10,
    fontWeight: '800',
    marginLeft: 4,
  },
  idExpiry: {
    color: '#64748b',
    fontSize: 9,
  },
  walletGrid: {
    flexDirection: 'row',
    gap: 12,
    marginBottom: 20,
  },
  walletItem: {
    flex: 1,
    backgroundColor: 'rgba(255, 255, 255, 0.03)',
    padding: 12,
    borderRadius: 16,
    borderWidth: 1,
    borderColor: 'rgba(255, 255, 255, 0.05)',
  },
  currencyLabel: {
    color: '#64748b',
    fontSize: 9,
    fontWeight: '700',
    marginBottom: 4,
  },
  currencyValueRow: {
    flexDirection: 'row',
    alignItems: 'center',
    gap: 6,
  },
  currencyValue: {
    color: '#ffffff',
    fontSize: 16,
    fontWeight: '900',
  },
  perfRow: {
    flexDirection: 'row',
    justifyContent: 'space-between',
    alignItems: 'flex-end',
  },
  perfLabel: {
    color: '#64748b',
    fontSize: 10,
    fontWeight: '800',
    letterSpacing: 1,
  },
  perfValueRow: {
    flexDirection: 'row',
    alignItems: 'baseline',
    gap: 4,
  },
  ptsValue: {
    color: '#FFB800',
    fontSize: 32,
    fontWeight: '900',
  },
  ptsUnit: {
    color: '#64748b',
    fontSize: 12,
    fontWeight: '700',
  },
  kmValue: {
    color: '#ffffff',
    fontSize: 20,
    fontWeight: '900',
  },
  kmUnit: {
    color: '#64748b',
    fontSize: 10,
    fontWeight: '700',
  },
  sectionHeader: {
    flexDirection: 'row',
    justifyContent: 'space-between',
    alignItems: 'center',
    marginBottom: 16,
  },
  sectionTitle: {
    color: '#ffffff',
    fontSize: 18,
    fontWeight: '900',
    textTransform: 'uppercase',
    fontStyle: 'italic',
  },
  periodText: {
    color: '#64748b',
    fontSize: 12,
    fontWeight: '600',
  },
  leagueCard: {
    marginBottom: 24,
    borderLeftWidth: 4,
    borderLeftColor: '#FFB800',
  },
  leagueTop: {
    flexDirection: 'row',
    justifyContent: 'space-between',
    alignItems: 'center',
    marginBottom: 8,
  },
  leagueRank: {
    color: '#ffffff',
    fontSize: 16,
    fontWeight: '900',
  },
  globalRank: {
    color: '#FFB800',
    fontSize: 11,
    fontWeight: '700',
  },
  progressBarBg: {
    height: 8,
    width: '100%',
    backgroundColor: 'rgba(255, 255, 255, 0.1)',
    borderRadius: 4,
    marginBottom: 12,
    overflow: 'hidden',
  },
  progressBarFill: {
    height: '100%',
    backgroundColor: '#FFB800',
    borderRadius: 4,
  },
  maintanceRow: {
    flexDirection: 'row',
    justifyContent: 'space-between',
    alignItems: 'center',
  },
  maintenanceIndicator: {
    flexDirection: 'row',
    alignItems: 'center',
    gap: 6,
  },
  maintenanceText: {
    color: '#4ade80',
    fontSize: 10,
    fontWeight: '700',
  },
  mapPreview: {
    height: 300,
    width: '100%',
    borderRadius: 32,
    backgroundColor: 'rgba(255, 255, 255, 0.05)',
    borderWidth: 1,
    borderColor: 'rgba(255, 255, 255, 0.1)',
    position: 'relative',
    overflow: 'hidden',
    justifyContent: 'center',
    alignItems: 'center',
    marginBottom: 24,
  },
  mapGrid: {
    flexDirection: 'row',
    flexWrap: 'wrap',
    gap: 8,
    width: '90%',
    height: '90%',
    opacity: 0.2,
  },
  mapCell: {
    width: (width * 0.9 - 64) / 4,
    aspectRatio: 1,
    backgroundColor: 'rgba(255, 255, 255, 0.1)',
    borderRadius: 12,
  },
  activeCell: {
    backgroundColor: 'rgba(255, 138, 0, 0.3)',
    borderWidth: 1,
    borderColor: '#FF8A00',
  },
  mapOverlay: {
    position: 'absolute',
    width: '80%',
  },
  conquestCard: {
    alignItems: 'center',
    padding: 20,
    borderWidth: 1,
    borderColor: 'rgba(255, 138, 0, 0.2)',
  },
  landTitle: {
    color: '#ffffff',
    fontSize: 14,
    fontWeight: '900',
    marginBottom: 4,
  },
  landDesc: {
    color: '#64748b',
    fontSize: 10,
    marginBottom: 16,
  },
  exploreBtn: {
    backgroundColor: '#FF8A00',
    paddingHorizontal: 24,
    paddingVertical: 12,
    borderRadius: 16,
    width: '100%',
    alignItems: 'center',
  },
  exploreBtnText: {
    color: '#000',
    fontSize: 12,
    fontWeight: '900',
  },
  lockCard: {
    flexDirection: 'row',
    alignItems: 'center',
    opacity: 0.6,
    marginBottom: 20,
  },
  lockIconContainer: {
    width: 44,
    height: 44,
    borderRadius: 14,
    backgroundColor: 'rgba(255, 255, 255, 0.03)',
    justifyContent: 'center',
    alignItems: 'center',
  },
  lockTextContainer: {
    flex: 1,
    marginLeft: 15,
  },
  lockTitle: {
    color: '#94a3b8',
    fontSize: 12,
    fontWeight: '800',
  },
  lockSubtitle: {
    color: '#475569',
    fontSize: 10,
    fontWeight: '600',
  },
  tabBar: {
    position: 'absolute',
    bottom: 0,
    flexDirection: 'row',
    backgroundColor: 'rgba(11, 18, 33, 0.95)',
    height: 80,
    width: '100%',
    borderTopWidth: 1,
    borderTopColor: 'rgba(255, 255, 255, 0.05)',
    justifyContent: 'space-around',
    paddingTop: 10,
    paddingBottom: 20,
  },
  tabItem: {
    alignItems: 'center',
    justifyContent: 'center',
  },
  tabText: {
    fontSize: 9,
    fontWeight: '800',
    color: '#64748b',
    marginTop: 4,
  },
  tabTextActive: {
    color: '#FF8A00',
  }
});
