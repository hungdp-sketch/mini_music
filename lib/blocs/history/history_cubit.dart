import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../models/song_model.dart';
import '../../services/history/history_service.dart';

abstract class HistoryState extends Equatable {
  const HistoryState();

  @override
  List<Object?> get props => [];
}

class HistoryInitial extends HistoryState {
  const HistoryInitial();
}

class HistoryLoading extends HistoryState {
  const HistoryLoading();
}

class HistoryLoaded extends HistoryState {
  final List<SongModel> songs;

  const HistoryLoaded(this.songs);

  @override
  List<Object?> get props => [songs];
}

class HistoryEmpty extends HistoryState {
  const HistoryEmpty();
}

class HistoryError extends HistoryState {
  final String message;

  const HistoryError(this.message);

  @override
  List<Object?> get props => [message];
}

class HistoryCubit extends Cubit<HistoryState> {
  final HistoryService historyService;

  HistoryCubit(this.historyService) : super(const HistoryInitial()) {
    loadRecently();
  }

  Future<void> loadRecently() async {
    try {
      emit(const HistoryLoading());
      final songs = await historyService.loadRecently();
      if (songs.isEmpty) {
        emit(const HistoryEmpty());
      } else {
        emit(HistoryLoaded(songs));
        // Preload URLs for recently played songs in background
        // YtAudioResolver.preloadRecentlySongs(songs);
      }
    } catch (e) {
      emit(HistoryError(e.toString()));
    }
  }

  Future<void> addRecently(SongModel song) async {
    try {
      await historyService.addSong(song);
      await loadRecently();
    } catch (e) {
      emit(HistoryError(e.toString()));
    }
  }

  Future<void> clearRecently() async {
    try {
      await historyService.clearHistory();
      emit(const HistoryEmpty());
    } catch (e) {
      emit(HistoryError(e.toString()));
    }
  }
}
